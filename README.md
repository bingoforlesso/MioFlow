# MioFlow

## 产品简介
MioFlow是一个基于React和FastAPI的现代化Web应用，提供安全可靠的用户认证系统。

## 功能特点
- 用户注册和登录
- 密码重置功能
- 会话管理
- 记住登录状态
- 登录尝试限制
- 多设备登录支持
- 令牌自动刷新

## 主要功能说明
- 用户认证：支持用户名/密码登录
- 会话管理：支持多设备同时登录，自动更新活动状态
- 安全特性：防暴力破解，异常登录检测
- 密码重置：通过邮件链接重置密码

## 技术栈
- 前端：React + TypeScript + Ant Design
- 后端：FastAPI + MySQL
- 认证：JWT + Session管理
- 安全：bcrypt密码加密

## 使用说明
1. 克隆仓库：
```bash
git clone https://github.com/bingoforlesso/MioFlow.git
```

2. 安装依赖：
```bash
# 后端依赖
pip install -r requirements.txt

# 前端依赖
cd src/client
npm install
```

3. 配置数据库：
```bash
# 配置MySQL连接信息
host: 127.0.0.1
port: 3306
user: root
password: Ac661978
```

4. 启动服务：
```bash
# 启动后端服务
uvicorn src.server.main:app --reload

# 启动前端服务
cd src/client
npm start
```

## 目录结构
```
MioFlow/
├── src/
│   ├── client/
│   │   ├── components/
│   │   ├── contexts/
│   │   └── api/
│   └── server/
│       ├── models/
│       ├── routes/
│       ├── utils/
│       └── main.py
├── requirements.txt
└── README.md
```

## 注意事项
- 确保MySQL服务已启动
- 配置正确的邮件服务器信息
- 在生产环境中修改密钥和敏感配置

## 服务器配置和维护
- 定期清理过期会话
- 监控登录尝试记录
- 备份数据库

## 常见问题说明
1. 登录限制：
   - 15分钟内最多失败5次
   - 24小时内最多失败10次
2. 会话过期：
   - 普通会话24小时过期
   - 记住登录状态30天过期

## 安全与建议
- 定期更改密码
- 启用双因素认证
- 注意异常登录提醒

## Cursor 历史下载链接
[待补充]