from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel

class Session(BaseModel):
    id: Optional[int] = None
    user_id: int
    token: str
    refresh_token: str
    device_info: str
    ip_address: str
    last_activity: datetime
    expires_at: datetime
    is_active: bool = True
    created_at: Optional[datetime] = None

    @classmethod
    def calculate_expiry(cls, remember_me: bool = False) -> datetime:
        """计算会话过期时间"""
        if remember_me:
            # 如果选择"记住我"，则会话保持30天
            return datetime.utcnow() + timedelta(days=30)
        else:
            # 否则会话保持24小时
            return datetime.utcnow() + timedelta(hours=24)