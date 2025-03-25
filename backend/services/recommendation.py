from typing import List, Optional
from models.product import Product
from models.user_behavior import UserBehavior
from services.redis_cache import RedisCache
from datetime import datetime, timedelta

class RecommendationService:
    def __init__(self):
        self.redis = RedisCache()
        
    async def get_recommendations(
        self,
        product_code: str,
        user_id: Optional[str] = None,
        limit: int = 5
    ) -> List[Product]:
        """获取商品推荐"""
        recommendations = []
        
        # 1. 获取相似商品
        similar_products = await self._get_similar_products(product_code)
        recommendations.extend(similar_products)
        
        # 2. 获取基于用户的推荐
        if user_id:
            user_recommendations = await self._get_user_based_recommendations(user_id)
            recommendations.extend(user_recommendations)
            
        # 3. 获取经常一起购买的商品
        frequently_bought = await self._get_frequently_bought_together(product_code)
        recommendations.extend(frequently_bought)
        
        # 4. 获取热门商品
        hot_products = await self._get_hot_products()
        recommendations.extend(hot_products)
        
        # 去重和排序
        unique_recommendations = self._deduplicate_recommendations(recommendations)
        sorted_recommendations = self._sort_recommendations(unique_recommendations)
        
        return sorted_recommendations[:limit]
    
    async def _get_similar_products(self, product_code: str) -> List[Product]:
        """获取相似商品"""
        cache_key = f"similar_products:{product_code}"
        cached = await self.redis.get(cache_key)
        
        if cached:
            return cached
            
        # 从数据库获取相似商品
        query = """
        SELECT p.* 
        FROM product_recommendation pr
        JOIN product_info p ON pr.target_product_code = p.code
        WHERE pr.source_product_code = :product_code
        AND pr.recommendation_type = 'similar'
        ORDER BY pr.score DESC
        LIMIT 5
        """
        products = await self.db.fetch_all(
            query=query,
            values={"product_code": product_code}
        )
        
        # 缓存结果
        await self.redis.set(cache_key, products, expire=3600)
        
        return products
        
    async def record_user_behavior(
        self,
        user_id: str,
        product_code: str,
        behavior_type: str,
        session_id: Optional[str] = None
    ):
        """记录用户行为"""
        behavior = UserBehavior(
            user_id=user_id,
            product_code=product_code,
            behavior_type=behavior_type,
            session_id=session_id
        )
        await behavior.save()
        
        # 更新热门商品缓存
        await self._update_hot_products(product_code)
        
    async def _update_hot_products(self, product_code: str):
        """更新热门商品缓存"""
        cache_key = "hot_products"
        score = 1
        
        await self.redis.zincrby(cache_key, score, product_code)
        # 24小时后过期
        await self.redis.expire(cache_key, 86400)