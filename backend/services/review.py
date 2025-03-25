from typing import Dict, List, Optional
from datetime import datetime
from models.review import Review, ReviewDetail
from services.dealer import DealerService
from services.product import ProductService

class ReviewService:
    def __init__(self):
        self.dealer_service = DealerService()
        self.product_service = ProductService()
        
    async def create_review(
        self,
        order_no: str,
        user_id: str,
        review_data: Dict
    ) -> int:
        """创建订单评价"""
        async with self.db.transaction():
            try:
                # 1. 创建主评价
                review_id = await self._create_main_review(order_no, user_id, review_data)
                
                # 2. 创建详细评价
                await self._create_detail_reviews(review_id, review_data["aspects"])
                
                # 3. 更新经销商评分
                await self._update_dealer_rating(review_data["dealer_id"])
                
                # 4. 更新商品评分
                await self._update_product_rating(review_data["product_code"])
                
                return review_id
                
            except Exception as e:
                await self.db.rollback()
                raise e
                
    async def _create_main_review(
        self,
        order_no: str,
        user_id: str,
        review_data: Dict
    ) -> int:
        """创建主评价记录"""
        query = """
        INSERT INTO review (
            order_no, product_code, dealer_id, 
            rating, comment, user_id
        ) VALUES (
            :order_no, :product_code, :dealer_id,
            :rating, :comment, :user_id
        )
        """
        result = await self.db.execute(
            query=query,
            values={
                "order_no": order_no,
                "product_code": review_data["product_code"],
                "dealer_id": review_data["dealer_id"],
                "rating": review_data["overall_rating"],
                "comment": review_data.get("comment"),
                "user_id": user_id
            }
        )
        return result
        
    async def _create_detail_reviews(
        self,
        review_id: int,
        aspects: Dict
    ):
        """创建详细评价"""
        query = """
        INSERT INTO review_detail (
            review_id, aspect, score, comment
        ) VALUES (
            :review_id, :aspect, :score, :comment
        )
        """
        for aspect, data in aspects.items():
            await self.db.execute(
                query=query,
                values={
                    "review_id": review_id,
                    "aspect": aspect,
                    "score": data["score"],
                    "comment": data.get("comment")
                }
            )
            
    async def get_product_reviews(
        self,
        product_code: str,
        page: int = 1,
        page_size: int = 10
    ) -> List[Dict]:
        """获取商品评价"""
        query = """
        SELECT 
            r.*,
            rd.aspect,
            rd.score as aspect_score,
            rd.comment as aspect_comment,
            u.username as reviewer_name
        FROM review r
        LEFT JOIN review_detail rd ON r.id = rd.review_id
        LEFT JOIN user u ON r.user_id = u.id
        WHERE r.product_code = :product_code
        ORDER BY r.created_at DESC
        LIMIT :limit OFFSET :offset
        """
        reviews = await self.db.fetch_all(
            query=query,
            values={
                "product_code": product_code,
                "limit": page_size,
                "offset": (page - 1) * page_size
            }
        )
        
        return self._format_reviews(reviews)
        
    def _format_reviews(self, reviews: List[Dict]) -> List[Dict]:
        """格式化评价数据"""
        formatted = {}
        for review in reviews:
            if review["id"] not in formatted:
                formatted[review["id"]] = {
                    "id": review["id"],
                    "order_no": review["order_no"],
                    "rating": review["rating"],
                    "comment": review["comment"],
                    "reviewer_name": review["reviewer_name"],
                    "created_at": review["created_at"],
                    "aspects": {}
                }
            
            if review["aspect"]:
                formatted[review["id"]]["aspects"][review["aspect"]] = {
                    "score": review["aspect_score"],
                    "comment": review["aspect_comment"]
                }
                
        return list(formatted.values())