import { db } from '../utils/db';
import { ProductService } from './ProductService';

interface CartItem {
  id: number;
  user_id: string;
  product_code: string;
  quantity: number;
  selected_attrs: {
    color?: string;
    length?: string;
  };
}

export class CartService {
  private productService: ProductService;

  constructor() {
    this.productService = new ProductService();
  }

  async addToCart(userId: string, productCode: string, attrs: any = {}, quantity: number = 1) {
    // 验证商品是否存在
    const product = await this.productService.getProductByCode(productCode);
    if (!product) {
      throw new Error('商品不存在');
    }

    // 检查购物车是否已有该商品
    const existingItem = await this.getCartItem(userId, productCode);
    
    if (existingItem) {
      // 更新数量
      return this.updateCartItemQuantity(
        existingItem.id,
        existingItem.quantity + quantity
      );
    }

    // 添加新商品到购物车
    const sql = `
      INSERT INTO cart (user_id, product_code, quantity, selected_attrs)
      VALUES (?, ?, ?, ?)
    `;

    try {
      await db.execute(sql, [
        userId,
        productCode,
        quantity,
        JSON.stringify(attrs)
      ]);
      return { success: true, message: '成功添加到购物车' };
    } catch (error) {
      console.error('Error adding to cart:', error);
      throw new Error('添加购物车失败');
    }
  }

  async getCartItems(userId: string) {
    const sql = `
      SELECT c.*, p.name as product_name, p.price, p.specification
      FROM cart c
      JOIN product_info p ON c.product_code = p.code
      WHERE c.user_id = ?
    `;

    try {
      const items = await db.query(sql, [userId]);
      return items;
    } catch (error) {
      console.error('Error getting cart items:', error);
      throw new Error('获取购物车失败');
    }
  }

  private async getCartItem(userId: string, productCode: string): Promise<CartItem | null> {
    const sql = `
      SELECT * FROM cart 
      WHERE user_id = ? AND product_code = ?
      LIMIT 1
    `;

    try {
      const [item] = await db.query(sql, [userId, productCode]);
      return item || null;
    } catch (error) {
      console.error('Error getting cart item:', error);
      throw new Error('获取购物车商品失败');
    }
  }

  private async updateCartItemQuantity(itemId: number, quantity: number) {
    const sql = `
      UPDATE cart 
      SET quantity = ?
      WHERE id = ?
    `;

    try {
      await db.execute(sql, [quantity, itemId]);
      return { success: true, message: '成功更新购物车' };
    } catch (error) {
      console.error('Error updating cart item:', error);
      throw new Error('更新购物车失败');
    }
  }
}