import { CartService } from '../../src/services/CartService';

describe('CartService', () => {
  let cartService: CartService;

  beforeEach(() => {
    cartService = new CartService();
  });

  describe('addToCart', () => {
    it('should add new item to cart', async () => {
      const userId = 'test-user';
      const productCode = 'TEST-001';
      const attrs = { color: '白色', length: '6M' };
      
      const result = await cartService.addToCart(userId, productCode, attrs);
      expect(result.success).toBe(true);
    });

    it('should update quantity for existing item', async () => {
      const userId = 'test-user';
      const productCode = 'TEST-001';
      
      // Add item first time
      await cartService.addToCart(userId, productCode);
      
      // Add same item second time
      const result = await cartService.addToCart(userId, productCode);
      expect(result.success).toBe(true);
    });

    it('should throw error for non-existent product', async () => {
      const userId = 'test-user';
      const productCode = 'NONEXISTENT';
      
      await expect(
        cartService.addToCart(userId, productCode)
      ).rejects.toThrow('商品不存在');
    });
  });

  describe('getCartItems', () => {
    it('should return cart items with product details', async () => {
      const userId = 'test-user';
      const items = await cartService.getCartItems(userId);
      
      expect(Array.isArray(items)).toBe(true);
      if (items.length > 0) {
        expect(items[0]).toHaveProperty('product_name');
        expect(items[0]).toHaveProperty('price');
        expect(items[0]).toHaveProperty('specification');
      }
    });

    it('should return empty array for new user', async () => {
      const userId = 'new-user';
      const items = await cartService.getCartItems(userId);
      expect(items).toEqual([]);
    });
  });
});