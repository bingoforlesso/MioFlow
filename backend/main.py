from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 创建应用实例
app = FastAPI(
    title="MioDing API",
    description="智能建材采购平台API",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 路由导入
from routes import product, cart, order, dealer, user

# 注册路由
app.include_router(product.router, prefix="/api/products", tags=["products"])
app.include_router(cart.router, prefix="/api/cart", tags=["cart"])
app.include_router(order.router, prefix="/api/orders", tags=["orders"])
app.include_router(dealer.router, prefix="/api/dealers", tags=["dealers"])
app.include_router(user.router, prefix="/api/users", tags=["users"])

@app.get("/")
async def root():
    return {"message": "Welcome to MioDing API"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", 8000)),
        reload=True
    )