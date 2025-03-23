from fastapi import APIRouter, HTTPException, Depends, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
import jwt

from ..models.user import User
from ..models.session import Session
from ..models.login_attempt import LoginAttempt
from ..database import db
from ..utils.email import send_reset_password_email

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class UserCreate(BaseModel):
    username: str
    password: str
    email: EmailStr
    phone: str

class UserLogin(BaseModel):
    username: str
    password: str
    remember_me: bool = False

class PasswordReset(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str

def get_client_info(request: Request) -> dict:
    """获取客户端信息"""
    return {
        "ip_address": request.client.host,
        "user_agent": request.headers.get("user-agent", ""),
        "device_info": request.headers.get("user-agent", "")  # 简化版本，实际可能需要更详细的设备信息解析
    }

@router.post("/register")
async def register(user_data: UserCreate):
    # 检查用户名是否已存在
    if db.get_user_by_username(user_data.username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户名已存在"
        )
    
    # 检查邮箱是否已存在
    if db.get_user_by_email(user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="邮箱已被注册"
        )

    # 创建新用户
    hashed_password = User.create_password_hash(user_data.password)
    user_id = db.create_user({
        "username": user_data.username,
        "email": user_data.email,
        "phone": user_data.phone,
        "hashed_password": hashed_password
    })

    return {"message": "注册成功", "user_id": user_id}

@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    request: Request = None,
    remember_me: bool = False
):
    client_info = get_client_info(request)
    
    # 检查登录尝试次数
    recent_attempts = db.get_recent_login_attempts(
        form_data.username,
        client_info["ip_address"]
    )
    
    if LoginAttempt.should_block_login(recent_attempts):
        remaining_time = "15分钟" if len(recent_attempts) < 10 else "24小时"
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"登录尝试次数过多，请在{remaining_time}后重试"
        )

    # 验证用户
    user = db.get_user_by_username(form_data.username)
    login_successful = False

    try:
        if not user or not User.verify_password(form_data.password, user["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="用户名或密码错误"
            )
        
        login_successful = True

        # 创建访问令牌
        access_token = User.create_access_token(
            data={"sub": user["username"]}
        )

        # 创建刷新令牌
        refresh_token = User.create_access_token(
            data={"sub": user["username"], "refresh": True}
        )

        # 创建会话
        session = Session(
            user_id=user["id"],
            token=access_token,
            refresh_token=refresh_token,
            device_info=client_info["device_info"],
            ip_address=client_info["ip_address"],
            last_activity=datetime.utcnow(),
            expires_at=Session.calculate_expiry(remember_me)
        )

        # 保存会话
        db.create_session(session.dict())

    finally:
        # 记录登录尝试
        db.record_login_attempt({
            "username": form_data.username,
            "ip_address": client_info["ip_address"],
            "attempt_time": datetime.utcnow(),
            "is_successful": login_successful,
            "user_agent": client_info["user_agent"]
        })

        if not login_successful:
            remaining = LoginAttempt.get_remaining_attempts(recent_attempts)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"用户名或密码错误。剩余尝试次数：15分钟内{remaining['fifteen_min_remaining']}次，24小时内{remaining['daily_remaining']}次"
            )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": {
            "id": user["id"],
            "username": user["username"],
            "email": user["email"]
        }
    }

@router.post("/logout")
async def logout(token: str = Depends(oauth2_scheme)):
    """登出用户"""
    db.invalidate_session(token)
    return {"message": "登出成功"}

@router.post("/refresh-token")
async def refresh_token(refresh_token: str):
    """刷新访问令牌"""
    try:
        # 验证刷新令牌
        payload = jwt.decode(refresh_token, User.SECRET_KEY, algorithms=[User.ALGORITHM])
        if not payload.get("refresh"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid refresh token"
            )
        
        username = payload.get("sub")
        if not username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid refresh token"
            )

        # 创建新的访问令牌
        new_access_token = User.create_access_token(
            data={"sub": username}
        )

        return {
            "access_token": new_access_token,
            "token_type": "bearer"
        }

    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )

@router.get("/session-info")
async def get_session_info(token: str = Depends(oauth2_scheme)):
    """获取当前会话信息"""
    session = db.get_active_session(token)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session not found or expired"
        )
    
    # 更新最后活动时间
    db.update_session_activity(session["id"])
    
    return {
        "session_id": session["id"],
        "last_activity": session["last_activity"],
        "expires_at": session["expires_at"],
        "device_info": session["device_info"]
    }