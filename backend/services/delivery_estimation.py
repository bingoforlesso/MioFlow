from typing import Dict, Optional
from datetime import datetime, timedelta
from models.delivery import DeliveryEstimation, DeliveryRecord
from services.weather import WeatherService
from services.traffic import TrafficService

class DeliveryEstimationService:
    def __init__(self):
        self.weather_service = WeatherService()
        self.traffic_service = TrafficService()
        
    async def estimate_delivery_time(
        self,
        order_no: str,
        dealer_id: int,
        delivery_address: Dict
    ) -> Dict:
        """预估配送时间"""
        # 1. 计算配送距离
        distance = await self._calculate_distance(dealer_id, delivery_address)
        
        # 2. 获取基础配送时间
        base_hours = await self._get_base_delivery_hours(dealer_id, distance)
        
        # 3. 获取实时因素
        weather_factor = await self.weather_service.get_weather_factor(delivery_address)
        traffic_factor = await self.traffic_service.get_traffic_factor(
            dealer_id,
            delivery_address
        )
        
        # 4. 计算最终预估时间
        estimated_hours = base_hours * weather_factor * traffic_factor
        
        # 5. 保存预估记录
        await self._save_estimation(
            order_no=order_no,
            dealer_id=dealer_id,
            estimated_hours=estimated_hours,
            distance=distance,
            factors={
                "weather": weather_factor,
                "traffic": traffic_factor
            }
        )
        
        return {
            "estimated_hours": estimated_hours,
            "distance": distance,
            "factors": {
                "weather": weather_factor,
                "traffic": traffic_factor
            }
        }
        
    async def _calculate_distance(self, dealer_id: int, delivery_address: Dict) -> float:
        """计算配送距离"""
        query = """
        SELECT ST_Distance_Sphere(
            (SELECT location FROM dealer WHERE id = :dealer_id),
            ST_GeomFromText(:delivery_point)
        ) / 1000 as distance_km
        """
        result = await self.db.fetch_one(
            query=query,
            values={
                "dealer_id": dealer_id,
                "delivery_point": f"POINT({delivery_address['longitude']} {delivery_address['latitude']})"
            }
        )
        return result["distance_km"]
        
    async def _get_base_delivery_hours(self, dealer_id: int, distance: float) -> float:
        """获取基础配送时间"""
        query = """
        SELECT min_hours, max_hours
        FROM delivery_estimation
        WHERE dealer_id = :dealer_id
        AND :distance BETWEEN 
            CAST(SUBSTRING_INDEX(distance_range, '-', 1) AS DECIMAL)
            AND CAST(SUBSTRING_INDEX(distance_range, '-', -1) AS DECIMAL)
        LIMIT 1
        """
        result = await self.db.fetch_one(
            query=query,
            values={
                "dealer_id": dealer_id,
                "distance": distance
            }
        )
        
        if not result:
            # 使用默认值
            return distance * 0.5  # 每公里0.5小时
            
        return (result["min_hours"] + result["max_hours"]) / 2
        
    async def update_actual_delivery_time(
        self,
        order_no: str,
        complete_time: datetime
    ):
        """更新实际配送时间"""
        query = """
        UPDATE delivery_record
        SET complete_time = :complete_time,
            actual_hours = TIMESTAMPDIFF(HOUR, start_time, :complete_time)
        WHERE order_no = :order_no
        """
        await self.db.execute(
            query=query,
            values={
                "complete_time": complete_time,
                "order_no": order_no
            }
        )