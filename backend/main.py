from fastapi import FastAPI, HTTPException, Query, Body, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional, List, Dict, Any, Set, Generator, Annotated
from pydantic import BaseModel, Field, ConfigDict
import mysql.connector
from mysql.connector import Error
import logging
import json
from enum import Enum
from collections import defaultdict
import time
from datetime import datetime, timedelta
from pypinyin import lazy_pinyin, Style
import re
import jieba
from sqlalchemy import or_, and_, create_engine, String, Enum as SQLAlchemyEnum
from sqlalchemy.sql.expression import cast
from sqlalchemy.types import String
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, Text, Numeric, JSON, DateTime
from fastapi import Depends
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 数据库配置
DATABASE_URL = f"mysql+mysqlconnector://{os.getenv('DB_USER', 'root')}:{os.getenv('DB_PASSWORD', 'Ac661978')}@{os.getenv('DB_HOST', '127.0.0.1')}:{os.getenv('DB_PORT', '3306')}/{os.getenv('DB_NAME', 'mioflow')}"

# 创建数据库引擎
engine = create_engine(DATABASE_URL)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建基类
Base = declarative_base()

# 产品模型
class Product(Base):
    __tablename__ = "product_info"

    id = Column(String(255), primary_key=True, index=True)
    code = Column(String(255), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    brand = Column(String(255), nullable=False)
    material_code = Column(String(255), nullable=False, index=True)
    output_brand = Column(String(255))
    product_name = Column(String(255))
    model = Column(String(255))
    specification = Column(String(100))
    color = Column(String(255))
    length = Column(String(255))
    weight = Column(String(255))
    wattage = Column(String(255))
    pressure = Column(String(255))
    degree = Column(String(255))
    material = Column(String(255))
    price = Column(Numeric(10, 2))
    product_type = Column(SQLAlchemyEnum('管件', '管材', '线槽', '阀门', '接头'))
    usage_type = Column(SQLAlchemyEnum('农业专用', '农业排水', '建筑排水'))
    sub_type = Column(SQLAlchemyEnum('弯头', '三通', '直通', '球阀', '闸阀', '截止阀'))

# 创建 FastAPI 应用
app = FastAPI(
    title="MioFlow API",
    description="MioFlow 后端 API 服务",
    version="1.0.1"
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 数据库配置
DB_CONFIG = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "Ac661978",
    "database": "mioflow"
}

# 缓存配置
CACHE_EXPIRY = 300  # 缓存过期时间（秒）
attribute_cache = {}  # 属性值缓存
filter_stats_cache = {}  # 筛选条件统计缓存

class CacheEntry:
    def __init__(self, data):
        self.data = data
        self.timestamp = time.time()

    def is_expired(self):
        return time.time() - self.timestamp > CACHE_EXPIRY

# 请求模型
class SearchRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "query": "水龙头",
                "page": 1,
                "page_size": 20,
                "filters": {
                    "品牌": ["联塑"],
                    "材质": ["不锈钢"]
                }
            }
        }
    )

    query: str
    page: int = 1
    page_size: int = 20
    filters: Dict[str, List[str]] = {}

# 测试请求模型
class TestRequest(BaseModel):
    query: str
    page: int = 1

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "query": "测试",
                "page": 1
            }
        }
    )

# 依赖项
def get_db() -> Generator[Session, None, None]:
    """
    获取数据库会话
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_pinyin(text: str) -> str:
    """获取文本的拼音表示"""
    return ''.join(lazy_pinyin(text, style=Style.NORMAL))

# 单位转换映射
unit_mapping = {
    '度': '°',
    '寸': 'inch',
    '米': 'm',
    'M': 'm',
    '厘米': 'cm',
    'CM': 'cm',
    '毫米': 'mm',
    'MM': 'mm',
    '升': 'L',
    '立方米': 'm³',
    '兆帕': 'MPa',
    '千帕': 'kPa',
    '帕': 'Pa',
    '千瓦': 'kW',
    '瓦': 'W',
    '千克': 'kg',
    '克': 'g',
    '牛': 'N',
    '千牛': 'kN'
}

# 同音字映射
homophone_mapping = {
    '联': '连',
    '津': '金',
    '立': '利',
    '星': '兴',
    '达': '大',
    '德': '得',
    '隆': '龙',
    '邦': '帮',
    '宝': '保',
    '盛': '胜'
}

# 缩写和别名映射
alias_mapping = {
    'ppr': 'PPR',
    'pvc': 'PVC',
    'upvc': 'UPVC',
    'pe': 'PE',
    'abs': 'ABS',
    'hdpe': 'HDPE',
    'cpvc': 'CPVC',
    'pp-r': 'PPR',
    'pvc-u': 'PVC-U',
    'dn': 'DN'
}

def normalize_text(text: str) -> str:
    """
    标准化文本，处理单位、同音字和缩写
    """
    if not text:
        return ""
        
    # 转换为小写以处理缩写
    lower_text = text.lower()
    
    # 处理缩写和别名
    for alias, full in alias_mapping.items():
        if alias in lower_text:
            text = text.replace(alias, full)
            
    # 处理单位
    for unit, replacement in unit_mapping.items():
        text = text.replace(unit, replacement)
        
    # 处理同音字
    for char, replacement in homophone_mapping.items():
        text = text.replace(char, replacement)
        
    return text.strip()

def fuzzy_match(text: str, query: str) -> bool:
    """
    智能模糊匹配
    """
    if not text or not query:
        return False
        
    # 标准化处理
    normalized_text = normalize_text(str(text).lower())
    normalized_query = normalize_text(query.lower())
    
    # 1. 完全匹配
    if normalized_query in normalized_text:
        return True
        
    # 2. 拼音匹配
    text_pinyin = ''.join(lazy_pinyin(text))
    query_pinyin = ''.join(lazy_pinyin(query))
    if query_pinyin in text_pinyin:
        return True
        
    # 3. 拼音首字母匹配
    text_pinyin_initials = ''.join([p[0] for p in lazy_pinyin(text)])
    query_pinyin_initials = ''.join([p[0] for p in lazy_pinyin(query)])
    if query_pinyin_initials in text_pinyin_initials:
        return True
        
    # 4. 数字和单位的智能匹配
    text_numbers = re.findall(r'\d+\.?\d*', text)
    query_numbers = re.findall(r'\d+\.?\d*', query)
    
    if text_numbers and query_numbers:
        for t_num in text_numbers:
            for q_num in query_numbers:
                try:
                    if abs(float(t_num) - float(q_num)) < 0.01:  # 允许小数点误差
                        # 如果数值匹配，检查单位是否兼容
                        text_unit = re.findall(r'[a-zA-Z°]+', text)
                        query_unit = re.findall(r'[a-zA-Z°]+', query)
                        if not text_unit or not query_unit or text_unit[0] == query_unit[0]:
                            return True
                except ValueError:
                    continue
    
    # 5. 分词匹配
    text_words = set(jieba.cut(normalized_text))
    query_words = set(jieba.cut(normalized_query))
    common_words = text_words & query_words
    
    # 如果查询词的大部分词都在文本中出现，认为是匹配的
    if len(common_words) >= len(query_words) * 0.7:  # 70% 匹配率
        return True
        
    return False

def analyze_search_results(results: List[Dict]) -> Dict[str, Dict]:
    """分析搜索结果，提取共同属性和可筛选维度"""
    cache_key = f"filter_stats_{hash(str(results))}"
    
    # 检查缓存
    if cache_key in filter_stats_cache:
        cache_entry = filter_stats_cache[cache_key]
        if not cache_entry.is_expired():
            return cache_entry.data
    
    attribute_stats = defaultdict(lambda: defaultdict(int))
    
    for product in results:
        # 分析基本属性
        for field in ['brand', 'material', 'product_type', 'usage_type', 'sub_type',
                     'specification', 'color', 'length', 'weight', 'pressure', 'degree',
                     'wattage']:
            if product.get(field):
                attribute_stats[field][str(product[field])] += 1
    
    result = dict(attribute_stats)
    
    # 更新缓存
    filter_stats_cache[cache_key] = CacheEntry(result)
    
    return result

def format_product(row: Dict[str, Any]) -> Dict[str, Any]:
    """格式化产品数据，保留所有可能的筛选属性"""
    attributes = {}
    
    # 基本属性
    basic_fields = {
        "brand": "品牌",
        "material": "材质",
        "specification": "规格",
        "color": "颜色",
        "length": "长度",
        "weight": "重量",
        "pressure": "压力",
        "degree": "度数",
        "wattage": "功率",
        "product_type": "产品类型",
        "usage_type": "使用类型",
        "sub_type": "子类型"
    }
    
    for field, label in basic_fields.items():
        if row.get(field):
            attributes[label] = [str(row[field])]

    return {
        "id": str(row["id"]),
        "code": row["code"],
        "name": row["name"],
        "description": row.get("product_name"),
        "price": str(row["price"]) if row.get("price") else None,
        "attributes": attributes,
        "image": None,
        "stock": 0,
        "created_at": None,
        "updated_at": None
    }

async def get_search_request(
    query: str,
    page: int = 1,
    page_size: int = 20,
    filters: Dict[str, List[str]] = {}
) -> SearchRequest:
    return SearchRequest(
        query=query,
        page=page,
        page_size=page_size,
        filters=filters
    )

@app.post("/api/v1/products/search")
async def search_products(
    search_request: SearchRequest = Body(...),
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    搜索产品
    """
    try:
        logger.info(f"开始搜索产品，查询参数: {search_request}")
        
        # 基础查询
        base_query = db.query(Product)
        
        if search_request.query:
            # 标准化查询文本
            normalized_query = normalize_text(search_request.query)
            query_pinyin = ''.join(lazy_pinyin(search_request.query))
            
            logger.info(f"标准化后的查询文本: {normalized_query}, 拼音: {query_pinyin}")
            
            # 构建查询条件
            search_conditions = []
            
            # 1. 名称匹配
            name_terms = list(jieba.cut(normalized_query))
            logger.info(f"分词结果: {name_terms}")
            
            # 标准化文本匹配
            search_conditions.append(
                or_(
                    Product.name.ilike(f"%{normalized_query}%"),
                    Product.product_name.ilike(f"%{normalized_query}%"),
                    Product.brand.ilike(f"%{normalized_query}%"),
                    # 添加灵活匹配
                    and_(
                        Product.name.ilike("%联塑%"),
                        or_(
                            Product.name.ilike("%管%"),
                            Product.name.ilike("%给水管%"),
                            Product.name.ilike("%排水管%"),
                            Product.name.ilike("%电工管%"),
                            Product.name.ilike("%套管%")
                        )
                    ),
                    and_(
                        Product.name.ilike("%连塑%"),
                        or_(
                            Product.name.ilike("%管%"),
                            Product.name.ilike("%给水管%"),
                            Product.name.ilike("%排水管%"),
                            Product.name.ilike("%电工管%"),
                            Product.name.ilike("%套管%")
                        )
                    ),
                    and_(
                        Product.product_name.ilike("%联塑%"),
                        or_(
                            Product.product_name.ilike("%管%"),
                            Product.product_name.ilike("%给水管%"),
                            Product.product_name.ilike("%排水管%"),
                            Product.product_name.ilike("%电工管%"),
                            Product.product_name.ilike("%套管%")
                        )
                    ),
                    and_(
                        Product.product_name.ilike("%连塑%"),
                        or_(
                            Product.product_name.ilike("%管%"),
                            Product.product_name.ilike("%给水管%"),
                            Product.product_name.ilike("%排水管%"),
                            Product.product_name.ilike("%电工管%"),
                            Product.product_name.ilike("%套管%")
                        )
                    )
                )
            )
            
            # 分词匹配
            for term in name_terms:
                if len(term.strip()) > 0:
                    search_conditions.append(
                        or_(
                            Product.name.ilike(f"%{term}%"),
                            Product.product_name.ilike(f"%{term}%"),
                            Product.brand.ilike(f"%{term}%"),
                            Product.material.ilike(f"%{term}%"),
                            Product.specification.ilike(f"%{term}%")
                        )
                    )
            
            # 合并查询条件
            if search_conditions:
                base_query = base_query.filter(or_(*search_conditions))
                logger.info("应用搜索条件")
        
        # 应用过滤器
        if search_request.filters:
            logger.info(f"应用过滤器: {search_request.filters}")
            filter_conditions = []
            for attr, values in search_request.filters.items():
                attr_conditions = []
                for value in values:
                    normalized_value = normalize_text(value)
                    if attr == "品牌":
                        attr_conditions.append(Product.brand.ilike(f"%{normalized_value}%"))
                    elif attr == "材质":
                        attr_conditions.append(Product.material.ilike(f"%{normalized_value}%"))
                    elif attr == "规格":
                        attr_conditions.append(Product.specification.ilike(f"%{normalized_value}%"))
                    elif attr == "颜色":
                        attr_conditions.append(Product.color.ilike(f"%{normalized_value}%"))
                    elif attr == "型号":
                        attr_conditions.append(Product.model.ilike(f"%{normalized_value}%"))
                    elif attr == "产品类型":
                        attr_conditions.append(Product.product_type == normalized_value)
                    elif attr == "使用类型":
                        attr_conditions.append(Product.usage_type == normalized_value)
                    elif attr == "子类型":
                        attr_conditions.append(Product.sub_type == normalized_value)
                if attr_conditions:
                    filter_conditions.append(or_(*attr_conditions))
            
            if filter_conditions:
                base_query = base_query.filter(and_(*filter_conditions))
                logger.info("应用过滤条件")
        
        # 执行查询
        total = base_query.count()
        logger.info(f"查询到总记录数: {total}")
        
        products = base_query.offset((search_request.page - 1) * search_request.page_size).limit(search_request.page_size).all()
        logger.info(f"当前页返回记录数: {len(products)}")
        
        # 提取可用的过滤器
        available_filters = {}
        if products:
            # 使用子查询获取匹配产品的所有属性
            all_products = base_query.all()
            logger.info(f"获取所有匹配产品用于过滤器: {len(all_products)}")
            
            # 收集过滤器值
            filter_mapping = {
                "品牌": "brand",
                "材质": "material",
                "规格": "specification",
                "颜色": "color",
                "型号": "model",
                "产品类型": "product_type",
                "使用类型": "usage_type",
                "子类型": "sub_type"
            }
            
            for label, field in filter_mapping.items():
                available_filters[label] = {}
                for product in all_products:
                    value = getattr(product, field)
                    if value:
                        available_filters[label][str(value)] = available_filters[label].get(str(value), 0) + 1
            
            logger.info("过滤器统计完成")
        
        # 格式化产品数据
        formatted_products = []
        for product in products:
            formatted_products.append({
                "id": product.id,
                "code": product.code,
                "name": product.name,
                "product_name": product.product_name,
                "brand": product.brand,
                "material": product.material,
                "specification": product.specification,
                "color": product.color,
                "model": product.model,
                "price": float(product.price) if product.price else None,
                "product_type": product.product_type,
                "usage_type": product.usage_type,
                "sub_type": product.sub_type,
                "length": product.length,
                "weight": product.weight,
                "wattage": product.wattage,
                "pressure": product.pressure,
                "degree": product.degree
            })
        
        logger.info("数据格式化完成")
        
        return {
            "success": True,
            "message": "搜索产品成功",
            "data": formatted_products,
            "meta": {
                "total": total,
                "page": search_request.page,
                "page_size": search_request.page_size,
                "total_pages": (total + search_request.page_size - 1) // search_request.page_size
            },
            "available_filters": available_filters
        }
            
    except Exception as e:
        logger.error(f"搜索产品时出错: {str(e)}")
        raise HTTPException(status_code=500, detail=f"搜索产品时出错: {str(e)}")

@app.get("/api/v1/products/attributes/{attribute}")
async def get_attribute_values(
    attribute: str,
    query: str = None,
    db: Session = Depends(SessionLocal)
) -> Dict[str, Any]:
    """
    获取产品属性值
    """
    try:
        # 查询所有产品的指定属性值
        products = db.query(Product).all()
        
        # 收集属性值
        values = {}
        for product in products:
            if attribute in product.attributes:
                value = product.attributes[attribute]
                if isinstance(value, list):
                    for v in value:
                        if query and not fuzzy_match(str(v), query):
                            continue
                        values[str(v)] = values.get(str(v), 0) + 1
                else:
                    if query and not fuzzy_match(str(value), query):
                        continue
                    values[str(value)] = values.get(str(value), 0) + 1
        
        # 转换为列表格式
        result = []
        for value, count in values.items():
            result.append({
                "value": value,
                "count": count,
                "pinyin": ''.join(lazy_pinyin(str(value))),
                "normalized": normalize_text(str(value))
            })
        
        return {
            "success": True,
            "message": f"获取{attribute}属性值成功",
            "data": result
        }
            
    except Exception as e:
        logger.error(f"获取属性值时出错: {str(e)}")
        raise HTTPException(status_code=500, detail=f"获取属性值时出错: {str(e)}")

# 定期清理过期缓存
@app.on_event("startup")
async def setup_cache_cleanup():
    def cleanup_cache():
        global logger  # 添加全局 logger 引用
        while True:
            try:
                time.sleep(CACHE_EXPIRY)
                current_time = time.time()
                
                # 清理属性缓存
                expired_keys = [
                    key for key, entry in attribute_cache.items()
                    if entry.is_expired()
                ]
                for key in expired_keys:
                    del attribute_cache[key]
                
                # 清理筛选条件缓存
                expired_keys = [
                    key for key, entry in filter_stats_cache.items()
                    if entry.is_expired()
                ]
                for key in expired_keys:
                    del filter_stats_cache[key]
                
                logger.info(f"已清理 {len(expired_keys)} 个过期缓存项")
            except Exception as e:
                logger.error(f"清理缓存时出错: {str(e)}")

    import threading
    cleanup_thread = threading.Thread(target=cleanup_cache, daemon=True)
    cleanup_thread.start()

@app.post("/api/v1/test_search")
async def test_search(
    test_request: TestRequest = Body(...)
) -> Dict[str, Any]:
    """
    测试搜索路由
    """
    return {
        "success": True,
        "message": "测试成功",
        "request": {
            "query": test_request.query,
            "page": test_request.page
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)