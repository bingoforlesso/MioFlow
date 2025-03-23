import { db } from '../utils/db';
import { CartService } from './CartService';

interface CreateOrderParams {
  userId: string;
  addressId: number;
  dealerId: number;
  items: Array<{
    productCode: string;
    quantity: number;
    unitPrice: number;
    selectedColor?: string;
    selectedLength?: string;
  }>;
}

export class OrderService {
  private cartService: CartService;

  constructor() {
    this.cartService = new CartService();
  }

  async createOrder(params: CreateOrderParams) {
    // 生成订单号 DD + 年月日 + 6位序号
    const orderNo = 'DD' + this.generateOrderNo();

    // 开启事务
    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      // 1. 创建订单主表记录
      const totalAmount = params.items.reduce(
        (sum, item) => sum + item.quantity * item.unitPrice,
        0
      );

      await connection.execute(
        `INSERT INTO \`order\` (
          order_no, user_id, dealer_id, 
          total_amount, address_id, status
        ) VALUES (?, ?, ?, ?, ?, 'pending')`,
        [orderNo, params.userId, params.dealerId, totalAmount, params.addressId]
      );

      // 2. 创建订单明细
      for (const item of params.items) {
        await connection.execute(
          `INSERT INTO order_item (
            order_no, product_code, quantity,
            unit_price, selected_color, selected_length
          ) VALUES (?, ?, ?, ?, ?, ?)`,
          [
            orderNo,
            item.productCode,
            item.quantity,
            item.unitPrice,
            item.selectedColor || null,
            item.selectedLength || null
          ]
        );
      }

      // 3. 清空用户购物车
      await connection.execute(
        'DELETE FROM cart WHERE user_id = ?',
        [params.userId]
      );

      // 提交事务
      await connection.commit();

      return {
        success: true,
        orderNo,
        message: '订单创建成功'
      };

    } catch (error) {
      // 回滚事务
      await connection.rollback();
      console.error('Error creating order:', error);
      throw new Error('订单创建失败');
    } finally {
      connection.release();
    }
  }

  private generateOrderNo(): string {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const random = Math.floor(Math.random() * 1000000).toString().padStart(6, '0');
    return `${year}${month}${day}${random}`;
  }

  async getOrderDetail(orderNo: string) {
    const sql = `
      SELECT 
        o.*,
        d.name as dealer_name,
        d.contact_phone as dealer_phone,
        ua.full_address,
        ua.contact_name,
        ua.phone as contact_phone
      FROM \`order\` o
      JOIN dealer d ON o.dealer_id = d.id
      JOIN user_address ua ON o.address_id = ua.id
      WHERE o.order_no = ?
    `;

    try {
      const [order] = await db.query(sql, [orderNo]);
      if (!order) {
        throw new Error('订单不存在');
      }

      // 获取订单明细
      const itemsSql = `
        SELECT oi.*, p.name as product_name
        FROM order_item oi
        JOIN product_info p ON oi.product_code = p.code
        WHERE oi.order_no = ?
      `;
      const items = await db.query(itemsSql, [orderNo]);

      return {
        ...order,
        items
      };
    } catch (error) {
      console.error('Error getting order detail:', error);
      throw new Error('获取订单详情失败');
    }
  }
}