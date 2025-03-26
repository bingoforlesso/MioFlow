# MioFlow 后端 API 服务

## 产品简介
MioFlow 后端 API 服务，提供产品数据的 RESTful API 接口。

## 功能特点
- 产品列表查询
- 产品详情获取
- 产品搜索功能
- 支持分页
- 支持过滤和排序
- 完整的错误处理
- 日志记录

## 主要功能说明
1. 获取产品列表：`GET /api/v1/products`
2. 获取产品详情：`GET /api/v1/products/{product_id}`
3. 搜索产品：`POST /api/v1/products/search`

## 技术栈
- Python 3.12+
- FastAPI
- MySQL
- Uvicorn

## 使用说明
1. 安装依赖：
```bash
pip install -r requirements.txt
```

2. 运行服务：
```bash
python main.py
```

3. 访问 API 文档：
```
http://127.0.0.1:8000/docs
```

## 目录结构
```
backend/
├── main.py          # 主程序
├── requirements.txt  # 依赖列表
└── README.md        # 说明文档
```

## 注意事项
- 确保 MySQL 服务已启动
- 检查数据库连接配置
- 建议在生产环境中使用环境变量

## 服务器配置和维护
- 端口：8000
- 主机：127.0.0.1
- 数据库：MySQL
- 日志文件：mioflow.log

## 常见问题说明
1. 数据库连接失败
   - 检查 MySQL 服务是否运行
   - 验证数据库凭据是否正确
   
2. API 访问超时
   - 检查网络连接
   - 验证服务器状态

## 安全与建议
- 在生产环境中使用 HTTPS
- 实施适当的身份验证和授权
- 定期备份数据库
- 监控服务器资源使用情况