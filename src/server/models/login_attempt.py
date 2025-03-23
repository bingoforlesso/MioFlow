from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel

class LoginAttempt(BaseModel):
    id: Optional[int] = None
    username: str
    ip_address: str
    attempt_time: datetime
    is_successful: bool
    user_agent: str

    @classmethod
    def should_block_login(cls, attempts: list['LoginAttempt']) -> bool:
        """
        检查是否应该阻止登录尝试
        规则：
        1. 15分钟内失败5次则阻止登录
        2. 24小时内失败10次则阻止登录
        """
        now = datetime.utcnow()
        fifteen_mins_ago = now - timedelta(minutes=15)
        one_day_ago = now - timedelta(days=1)

        # 统计最近15分钟的失败次数
        recent_failures = sum(
            1 for attempt in attempts
            if not attempt.is_successful and attempt.attempt_time >= fifteen_mins_ago
        )
        if recent_failures >= 5:
            return True

        # 统计24小时内的失败次数
        daily_failures = sum(
            1 for attempt in attempts
            if not attempt.is_successful and attempt.attempt_time >= one_day_ago
        )
        if daily_failures >= 10:
            return True

        return False

    @classmethod
    def get_remaining_attempts(cls, attempts: list['LoginAttempt']) -> dict:
        """获取剩余的登录尝试次数"""
        now = datetime.utcnow()
        fifteen_mins_ago = now - timedelta(minutes=15)
        one_day_ago = now - timedelta(days=1)

        recent_failures = sum(
            1 for attempt in attempts
            if not attempt.is_successful and attempt.attempt_time >= fifteen_mins_ago
        )
        daily_failures = sum(
            1 for attempt in attempts
            if not attempt.is_successful and attempt.attempt_time >= one_day_ago
        )

        return {
            "fifteen_min_remaining": max(0, 5 - recent_failures),
            "daily_remaining": max(0, 10 - daily_failures)
        }