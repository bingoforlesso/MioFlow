import { db } from '../utils/db';

interface ProductSearchParams {
  brand?: string;
  specification?: string;
  pressure?: string;
  color?: string;
  length?: string;
}

export class ProductService {
  async searchProducts(params: ProductSearchParams) {
    const conditions: string[] = [];
    const values: any[] = [];

    if (params.brand) {
      conditions.push('brand = ?');
      values.push(params.brand);
    }
    if (params.specification) {
      conditions.push('specification = ?');
      values.push(params.specification);
    }
    if (params.pressure) {
      conditions.push('pressure = ?');
      values.push(params.pressure);
    }
    if (params.color) {
      conditions.push('color = ?');
      values.push(params.color);
    }
    if (params.length) {
      conditions.push('length = ?');
      values.push(params.length);
    }

    const whereClause = conditions.length > 0 
      ? 'WHERE ' + conditions.join(' AND ')
      : '';

    const sql = `
      SELECT * FROM product_info 
      ${whereClause}
      LIMIT 10
    `;

    try {
      const products = await db.query(sql, values);
      return products;
    } catch (error) {
      console.error('Error searching products:', error);
      throw new Error('商品查询失败');
    }
  }

  async getProductByCode(code: string) {
    const sql = 'SELECT * FROM product_info WHERE code = ? LIMIT 1';
    try {
      const [product] = await db.query(sql, [code]);
      return product;
    } catch (error) {
      console.error('Error getting product:', error);
      throw new Error('获取商品详情失败');
    }
  }
}