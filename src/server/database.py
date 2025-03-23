from typing import Optional, List
import mysql.connector
from mysql.connector import Error
from contextlib import contextmanager
from datetime import datetime

class Database:
    def __init__(self):
        self.config = {
            'host': '127.0.0.1',
            'port': 3306,
            'user': 'root',
            'password': 'Ac661978',
            'database': 'mioding'
        }

    @contextmanager
    def get_connection(self):
        connection = None
        try:
            connection = mysql.connector.connect(**self.config)
            yield connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            raise
        finally:
            if connection and connection.is_connected():
                connection.close()

    def initialize_database(self):
        """初始化数据库表"""
        create_users_table = """
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            phone VARCHAR(20) UNIQUE NOT NULL,
            hashed_password VARCHAR(255) NOT NULL,
            reset_token VARCHAR(255),
            reset_token_expires DATETIME,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
        """
        
        create_sessions_table = """
        CREATE TABLE IF NOT EXISTS sessions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            token VARCHAR(255) NOT NULL,
            refresh_token VARCHAR(255) NOT NULL,
            device_info VARCHAR(255),
            ip_address VARCHAR(45),
            last_activity DATETIME NOT NULL,
            expires_at DATETIME NOT NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
        """

        create_login_attempts_table = """
        CREATE TABLE IF NOT EXISTS login_attempts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL,
            ip_address VARCHAR(45) NOT NULL,
            attempt_time DATETIME NOT NULL,
            is_successful BOOLEAN NOT NULL,
            user_agent VARCHAR(255),
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """
        
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(create_users_table)
            cursor.execute(create_sessions_table)
            cursor.execute(create_login_attempts_table)
            connection.commit()

    # 用户相关方法
    def get_user_by_username(self, username: str) -> Optional[dict]:
        """通过用户名获取用户"""
        query = "SELECT * FROM users WHERE username = %s"
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, (username,))
            return cursor.fetchone()

    def get_user_by_email(self, email: str) -> Optional[dict]:
        """通过邮箱获取用户"""
        query = "SELECT * FROM users WHERE email = %s"
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, (email,))
            return cursor.fetchone()

    def create_user(self, user_data: dict) -> int:
        """创建新用户"""
        query = """
        INSERT INTO users (username, email, phone, hashed_password)
        VALUES (%s, %s, %s, %s)
        """
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(query, (
                user_data['username'],
                user_data['email'],
                user_data['phone'],
                user_data['hashed_password']
            ))
            connection.commit()
            return cursor.lastrowid

    # 会话相关方法
    def create_session(self, session_data: dict) -> int:
        """创建新会话"""
        query = """
        INSERT INTO sessions (user_id, token, refresh_token, device_info, 
                            ip_address, last_activity, expires_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(query, (
                session_data['user_id'],
                session_data['token'],
                session_data['refresh_token'],
                session_data['device_info'],
                session_data['ip_address'],
                session_data['last_activity'],
                session_data['expires_at']
            ))
            connection.commit()
            return cursor.lastrowid

    def get_active_session(self, token: str) -> Optional[dict]:
        """获取活动会话"""
        query = """
        SELECT * FROM sessions 
        WHERE token = %s AND is_active = TRUE AND expires_at > NOW()
        """
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, (token,))
            return cursor.fetchone()

    def update_session_activity(self, session_id: int):
        """更新会话最后活动时间"""
        query = """
        UPDATE sessions 
        SET last_activity = NOW()
        WHERE id = %s
        """
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(query, (session_id,))
            connection.commit()

    def invalidate_session(self, token: str):
        """使会话失效"""
        query = """
        UPDATE sessions 
        SET is_active = FALSE
        WHERE token = %s
        """
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(query, (token,))
            connection.commit()

    # 登录尝试相关方法
    def record_login_attempt(self, attempt_data: dict):
        """记录登录尝试"""
        query = """
        INSERT INTO login_attempts (username, ip_address, attempt_time, 
                                  is_successful, user_agent)
        VALUES (%s, %s, %s, %s, %s)
        """
        with self.get_connection() as connection:
            cursor = connection.cursor()
            cursor.execute(query, (
                attempt_data['username'],
                attempt_data['ip_address'],
                attempt_data['attempt_time'],
                attempt_data['is_successful'],
                attempt_data['user_agent']
            ))
            connection.commit()

    def get_recent_login_attempts(self, username: str, ip_address: str) -> List[dict]:
        """获取最近的登录尝试"""
        query = """
        SELECT * FROM login_attempts 
        WHERE (username = %s OR ip_address = %s)
        AND attempt_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ORDER BY attempt_time DESC
        """
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, (username, ip_address))
            return cursor.fetchall()

# 创建数据库实例
db = Database()