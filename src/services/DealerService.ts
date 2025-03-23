import { db } from '../utils/db';

export class DealerService {
  async findDealersByLocation(lat: number, lng: number) {
    const sql = `
      SELECT 
        d.*,
        ST_Distance_Sphere(
          service_area,
          POINT(?, ?)
        ) as distance
      FROM dealer d
      WHERE ST_Contains(service_area, POINT(?, ?))
      ORDER BY distance ASC
      LIMIT 10
    `;

    try {
      const dealers = await db.query(sql, [lng, lat, lng, lat]);
      return dealers;
    } catch (error) {
      console.error('Error finding dealers:', error);
      throw new Error('查询经销商失败');
    }
  }

  async getDealerStock(dealerId: number, productCodes: string[]) {
    const sql = `
      SELECT ds.*, p.name as product_name
      FROM dealer_stock ds
      JOIN product_info p ON ds.product_code = p.code
      WHERE ds.dealer_id = ?
      AND ds.product_code IN (?)
    `;

    try {
      const stock = await db.query(sql, [dealerId, productCodes]);
      return stock;
    } catch (error) {
      console.error('Error getting dealer stock:', error);
      throw new Error('查询库存失败');
    }
  }

  async getDealerById(dealerId: number) {
    const sql = `
      SELECT * FROM dealer
      WHERE id = ?
      LIMIT 1
    `;

    try {
      const [dealer] = await db.query(sql, [dealerId]);
      if (!dealer) {
        throw new Error('经销商不存在');
      }
      return dealer;
    } catch (error) {
      console.error('Error getting dealer:', error);
      throw new Error('获取经销商信息失败');
    }
  }
}