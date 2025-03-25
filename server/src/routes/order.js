import express from 'express';
import Order from '../models/order.js';
import OrderItem from '../models/order_item.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// 获取订单列表
router.get('/', auth, async (req, res, next) => {
  try {
    const orders = await Order.findAll({
      where: { userId: req.user.id },
      include: [OrderItem],
      order: [['createdAt', 'DESC']]
    });
    
    const formattedOrders = orders.map(order => {
      const data = order.toJSON();
      data.totalAmount = Number(data.totalAmount);
      data.OrderItems = data.OrderItems.map(item => ({
        ...item,
        price: Number(item.price)
      }));
      return data;
    });

    res.json({
      success: true,
      data: formattedOrders
    });
  } catch (error) {
    next(error);
  }
});

// 获取订单详情
router.get('/:orderNo', auth, async (req, res, next) => {
  try {
    const order = await Order.findOne({
      where: { 
        orderNo: req.params.orderNo,
        userId: req.user.id
      },
      include: [OrderItem]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        error: {
          message: '订单不存在'
        }
      });
    }

    const data = order.toJSON();
    data.totalAmount = Number(data.totalAmount);
    data.OrderItems = data.OrderItems.map(item => ({
      ...item,
      price: Number(item.price)
    }));

    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    next(error);
  }
});

// 创建订单
router.post('/', auth, async (req, res, next) => {
  try {
    const orderNo = `ORD${Date.now()}${Math.floor(Math.random() * 1000)}`;
    const order = await Order.create({
      ...req.body,
      orderNo,
      userId: req.user.id
    });

    if (req.body.items && req.body.items.length > 0) {
      await OrderItem.bulkCreate(
        req.body.items.map(item => ({
          ...item,
          orderId: order.id
        }))
      );
    }

    const createdOrder = await Order.findByPk(order.id, {
      include: [OrderItem]
    });

    const data = createdOrder.toJSON();
    data.totalAmount = Number(data.totalAmount);
    data.OrderItems = data.OrderItems.map(item => ({
      ...item,
      price: Number(item.price)
    }));

    res.status(201).json({
      success: true,
      data: data
    });
  } catch (error) {
    next(error);
  }
});

export default router; 