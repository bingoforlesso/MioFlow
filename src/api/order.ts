import express from 'express';
import { OrderService } from '../services/OrderService';

const router = express.Router();
const orderService = new OrderService();

router.post('/create', async (req, res) => {
  try {
    const orderParams = req.body;
    const result = await orderService.createOrder(orderParams);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      error: '创建订单失败',
      message: error.message
    });
  }
});

router.get('/:orderNo', async (req, res) => {
  try {
    const { orderNo } = req.params;
    const order = await orderService.getOrderDetail(orderNo);
    res.json(order);
  } catch (error) {
    res.status(500).json({
      error: '获取订单详情失败',
      message: error.message
    });
  }
});

export default router;