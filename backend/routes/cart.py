from fastapi import APIRouter, HTTPException
from typing import List, Optional
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/")
async def get_cart():
    return {"message": "获取购物车信息"}