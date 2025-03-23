import express from 'express';
import { CartService } from '../services/CartService';

const router = express.Router();
const cartService = new CartService();

router.post('/add', async (req, res) => {
  try {
    const { userId, productCode, attrs, quantity } = req.body;
    const result = await cartService.addToCart(userId, productCode, attrs, quantity);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      error: '添加购物车失败',
      message: error.message
    });
  }
});

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const items = await cartService.getCartItems(userId);
    res.json(items);
  } catch (error) {
    res.status(500).json({
      error: '获取购物车失败',
      message: error.message
    });
  }
});

export default router;