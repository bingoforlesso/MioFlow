from datetime import datetime, timedelta
from typing import Optional
import jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr
from fastapi import HTTPException, status

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT配置
SECRET_KEY = "your-secret-key"  # 在生产环境中应该使用环境变量
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class User(BaseModel):
    id: Optional[int] = None
    username: str
    email: EmailStr
    phone: str
    hashed_password: str
    reset_token: Optional[str] = None
    reset_token_expires: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @classmethod
    def create_password_hash(cls, password: str) -> str:
        return pwd_context.hash(password)

    @classmethod
    def verify_password(cls, plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password, hashed_password)

    @classmethod
    def create_access_token(cls, data: dict) -> str:
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    @classmethod
    def verify_token(cls, token: str) -> dict:
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )

    def create_password_reset_token(self) -> str:
        """创建密码重置令牌"""
        reset_token = jwt.encode(
            {
                "user_id": self.id,
                "exp": datetime.utcnow() + timedelta(hours=24)
            },
            SECRET_KEY,
            algorithm=ALGORITHM
        )
        self.reset_token = reset_token
        self.reset_token_expires = datetime.utcnow() + timedelta(hours=24)
        return reset_token

    @classmethod
    def verify_reset_token(cls, token: str) -> int:
        """验证密码重置令牌"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload["user_id"]
        except (jwt.ExpiredSignatureError, jwt.JWTError):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token"
            )