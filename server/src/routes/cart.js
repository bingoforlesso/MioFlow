import express from 'express';
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';
import auth from '../middleware/auth.js';
import { ProductInfo } from '../models/product.js';

const router = express.Router();

// 定义购物车模型
const CartItem = sequelize.define('CartItem', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.STRING,
    allowNull: false
  },
  productId: {
    type: DataTypes.STRING,
    allowNull: false,
    references: {
      model: ProductInfo,
      key: 'id'
    }
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  selectedAttributes: {
    type: DataTypes.JSON,
    allowNull: true
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'cart_items'
});

// 关联关系
CartItem.belongsTo(ProductInfo, { foreignKey: 'productId' });

// 同步模型（如果表不存在则创建）
sequelize.sync();

/**
 * @swagger
 * /api/v1/cart:
 *   get:
 *     summary: 获取用户购物车
 *     tags: [购物车]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 成功获取购物车
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       quantity:
 *                         type: integer
 *                         example: 2
 *                       selectedAttributes:
 *                         type: object
 *                       product:
 *                         type: object
 */
router.get('/', auth, async (req, res, next) => {
  try {
    const cartItems = await CartItem.findAll({
      where: { userId: req.user.id },
      include: [ProductInfo]
    });
    
    res.json({
      success: true,
      data: cartItems.map(item => {
        const data = item.toJSON();
        return {
          id: data.id,
          quantity: data.quantity,
          selectedAttributes: data.selectedAttributes,
          product: data.ProductInfo
        };
      })
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/cart/add:
 *   post:
 *     summary: 添加商品到购物车
 *     tags: [购物车]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - productId
 *             properties:
 *               productId:
 *                 type: string
 *                 example: "1759509602912706622"
 *               quantity:
 *                 type: integer
 *                 example: 1
 *               attributes:
 *                 type: object
 *     responses:
 *       201:
 *         description: 成功添加到购物车
 *       400:
 *         description: 无效的请求
 *       404:
 *         description: 商品不存在
 */
router.post('/add', auth, async (req, res, next) => {
  try {
    const { productId, quantity = 1, attributes = {} } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        error: {
          message: '缺少商品ID'
        }
      });
    }
    
    // 检查商品是否存在
    const product = await ProductInfo.findByPk(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '商品不存在'
        }
      });
    }
    
    // 检查购物车中是否已有该商品
    const existingItem = await CartItem.findOne({
      where: {
        userId: req.user.id,
        productId: productId
      }
    });
    
    if (existingItem) {
      // 如果已存在，更新数量
      existingItem.quantity += quantity;
      await existingItem.save();
      
      return res.json({
        success: true,
        message: '成功更新购物车',
        data: {
          id: existingItem.id,
          quantity: existingItem.quantity
        }
      });
    }
    
    // 如果不存在，创建新项目
    const cartItem = await CartItem.create({
      userId: req.user.id,
      productId: productId,
      quantity: quantity,
      selectedAttributes: attributes
    });
    
    res.status(201).json({
      success: true,
      message: '成功添加到购物车',
      data: {
        id: cartItem.id,
        quantity: cartItem.quantity
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/cart/{itemId}:
 *   put:
 *     summary: 更新购物车商品数量
 *     tags: [购物车]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: itemId
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - quantity
 *             properties:
 *               quantity:
 *                 type: integer
 *                 example: 2
 *     responses:
 *       200:
 *         description: 成功更新数量
 *       400:
 *         description: 无效的请求
 *       404:
 *         description: 购物车项目不存在
 */
router.put('/:itemId', auth, async (req, res, next) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;
    
    if (!quantity || quantity < 1) {
      return res.status(400).json({
        success: false,
        error: {
          message: '数量必须大于0'
        }
      });
    }
    
    const cartItem = await CartItem.findOne({
      where: {
        id: itemId,
        userId: req.user.id
      }
    });
    
    if (!cartItem) {
      return res.status(404).json({
        success: false,
        error: {
          message: '购物车项目不存在'
        }
      });
    }
    
    cartItem.quantity = quantity;
    await cartItem.save();
    
    res.json({
      success: true,
      message: '成功更新数量',
      data: {
        id: cartItem.id,
        quantity: cartItem.quantity
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/cart/{itemId}:
 *   delete:
 *     summary: 删除购物车项目
 *     tags: [购物车]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: itemId
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: 成功从购物车中移除
 *       404:
 *         description: 购物车项目不存在
 */
router.delete('/:itemId', auth, async (req, res, next) => {
  try {
    const { itemId } = req.params;
    
    const cartItem = await CartItem.findOne({
      where: {
        id: itemId,
        userId: req.user.id
      }
    });
    
    if (!cartItem) {
      return res.status(404).json({
        success: false,
        error: {
          message: '购物车项目不存在'
        }
      });
    }
    
    await cartItem.destroy();
    
    res.json({
      success: true,
      message: '成功从购物车中移除'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/cart:
 *   delete:
 *     summary: 清空购物车
 *     tags: [购物车]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 成功清空购物车
 */
router.delete('/', auth, async (req, res, next) => {
  try {
    await CartItem.destroy({
      where: {
        userId: req.user.id
      }
    });
    
    res.json({
      success: true,
      message: '成功清空购物车'
    });
  } catch (error) {
    next(error);
  }
});

export default router;