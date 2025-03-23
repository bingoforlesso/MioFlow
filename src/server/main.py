from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .routes import auth
from .database import db

app = FastAPI(title="MioDing API")

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # 允许的前端域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化数据库
@app.on_event("startup")
async def startup_event():
    db.initialize_database()

# 注册路由
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])