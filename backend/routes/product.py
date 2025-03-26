from fastapi import APIRouter, HTTPException
from typing import List, Optional
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/")
async def list_products():
    return {"message": "获取产品列表"}