import express from 'express';
import { DataTypes, Op } from 'sequelize';
import sequelize from '../config/database.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// 定义地址模型
const Address = sequelize.define('Address', {
  id: {
    type: DataTypes.STRING,
    primaryKey: true,
    defaultValue: () => `A${Date.now()}`
  },
  userId: {
    type: DataTypes.STRING,
    allowNull: false
  },
  receiver: {
    type: DataTypes.STRING,
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false
  },
  province: {
    type: DataTypes.STRING,
    allowNull: false
  },
  city: {
    type: DataTypes.STRING,
    allowNull: false
  },
  district: {
    type: DataTypes.STRING,
    allowNull: false
  },
  detail: {
    type: DataTypes.STRING,
    allowNull: false
  },
  is_default: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false
  },
  tag: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'addresses'
});

// 同步模型
sequelize.sync();

/**
 * @swagger
 * /api/v1/addresses:
 *   get:
 *     summary: 获取用户的所有地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 成功获取地址列表
 */
router.get('/', auth, async (req, res, next) => {
  try {
    const addresses = await Address.findAll({
      where: {
        userId: req.user.id
      },
      order: [
        ['is_default', 'DESC'],
        ['created_at', 'DESC']
      ]
    });
    
    res.json({
      success: true,
      data: addresses
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses/default:
 *   get:
 *     summary: 获取用户的默认地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 成功获取默认地址
 *       404:
 *         description: 默认地址不存在
 */
router.get('/default', auth, async (req, res, next) => {
  try {
    const address = await Address.findOne({
      where: {
        userId: req.user.id,
        is_default: true
      }
    });
    
    if (!address) {
      return res.status(404).json({
        success: false,
        error: {
          message: '默认地址不存在'
        }
      });
    }
    
    res.json({
      success: true,
      data: address
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses/{id}:
 *   get:
 *     summary: 获取地址详情
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 地址ID
 *     responses:
 *       200:
 *         description: 成功获取地址详情
 *       403:
 *         description: 无权访问该地址
 *       404:
 *         description: 地址不存在
 */
router.get('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const address = await Address.findByPk(id);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        error: {
          message: '地址不存在'
        }
      });
    }
    
    // 确保用户只能访问自己的地址
    if (address.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: {
          message: '无权访问该地址'
        }
      });
    }
    
    res.json({
      success: true,
      data: address
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses:
 *   post:
 *     summary: 创建新地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - receiver
 *               - phone
 *               - province
 *               - city
 *               - district
 *               - detail
 *             properties:
 *               receiver:
 *                 type: string
 *                 example: "张三"
 *               phone:
 *                 type: string
 *                 example: "13800138000"
 *               province:
 *                 type: string
 *                 example: "广东省"
 *               city:
 *                 type: string
 *                 example: "深圳市"
 *               district:
 *                 type: string
 *                 example: "南山区"
 *               detail:
 *                 type: string
 *                 example: "科技园南区8栋101"
 *               is_default:
 *                 type: boolean
 *                 example: false
 *               tag:
 *                 type: string
 *                 example: "公司"
 *     responses:
 *       201:
 *         description: 成功创建地址
 *       400:
 *         description: 无效请求
 */
router.post('/', auth, async (req, res, next) => {
  try {
    const { receiver, phone, province, city, district, detail, is_default, tag } = req.body;
    
    // 验证必填字段
    if (!receiver || !phone || !province || !city || !district || !detail) {
      return res.status(400).json({
        success: false,
        error: {
          message: '收货人、手机号、省市区和详细地址不能为空'
        }
      });
    }
    
    // 如果设为默认地址，则将其他地址设为非默认
    if (is_default) {
      await Address.update(
        { is_default: false },
        {
          where: {
            userId: req.user.id,
            is_default: true
          }
        }
      );
    }
    
    // 如果是用户的第一个地址，则自动设为默认地址
    const addressCount = await Address.count({
      where: {
        userId: req.user.id
      }
    });
    
    const address = await Address.create({
      userId: req.user.id,
      receiver,
      phone,
      province,
      city,
      district,
      detail,
      is_default: is_default || addressCount === 0, // 第一个地址自动设为默认
      tag
    });
    
    res.status(201).json({
      success: true,
      data: address
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses/{id}:
 *   put:
 *     summary: 更新地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 地址ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               receiver:
 *                 type: string
 *               phone:
 *                 type: string
 *               province:
 *                 type: string
 *               city:
 *                 type: string
 *               district:
 *                 type: string
 *               detail:
 *                 type: string
 *               is_default:
 *                 type: boolean
 *               tag:
 *                 type: string
 *     responses:
 *       200:
 *         description: 成功更新地址
 *       403:
 *         description: 无权修改该地址
 *       404:
 *         description: 地址不存在
 */
router.put('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { receiver, phone, province, city, district, detail, is_default, tag } = req.body;
    
    const address = await Address.findByPk(id);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        error: {
          message: '地址不存在'
        }
      });
    }
    
    // 确保用户只能修改自己的地址
    if (address.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: {
          message: '无权修改该地址'
        }
      });
    }
    
    // 如果设为默认地址，则将其他地址设为非默认
    if (is_default && !address.is_default) {
      await Address.update(
        { is_default: false },
        {
          where: {
            userId: req.user.id,
            is_default: true
          }
        }
      );
    }
    
    // 更新地址信息
    if (receiver) address.receiver = receiver;
    if (phone) address.phone = phone;
    if (province) address.province = province;
    if (city) address.city = city;
    if (district) address.district = district;
    if (detail) address.detail = detail;
    if (typeof is_default === 'boolean') address.is_default = is_default;
    if (tag !== undefined) address.tag = tag;
    
    await address.save();
    
    res.json({
      success: true,
      data: address
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses/{id}/default:
 *   put:
 *     summary: 设置为默认地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 地址ID
 *     responses:
 *       200:
 *         description: 成功设置默认地址
 *       403:
 *         description: 无权修改该地址
 *       404:
 *         description: 地址不存在
 */
router.put('/:id/default', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const address = await Address.findByPk(id);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        error: {
          message: '地址不存在'
        }
      });
    }
    
    // 确保用户只能修改自己的地址
    if (address.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: {
          message: '无权修改该地址'
        }
      });
    }
    
    // 将其他地址设为非默认
    await Address.update(
      { is_default: false },
      {
        where: {
          userId: req.user.id,
          is_default: true
        }
      }
    );
    
    // 设置当前地址为默认
    address.is_default = true;
    await address.save();
    
    res.json({
      success: true,
      data: address
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/addresses/{id}:
 *   delete:
 *     summary: 删除地址
 *     tags: [地址管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 地址ID
 *     responses:
 *       200:
 *         description: 成功删除地址
 *       403:
 *         description: 无权删除该地址
 *       404:
 *         description: 地址不存在
 */
router.delete('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const address = await Address.findByPk(id);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        error: {
          message: '地址不存在'
        }
      });
    }
    
    // 确保用户只能删除自己的地址
    if (address.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: {
          message: '无权删除该地址'
        }
      });
    }
    
    // 如果删除的是默认地址，则将最新添加的地址设为默认
    if (address.is_default) {
      const newDefault = await Address.findOne({
        where: {
          userId: req.user.id,
          id: { [Op.ne]: id }
        },
        order: [['created_at', 'DESC']]
      });
      
      if (newDefault) {
        newDefault.is_default = true;
        await newDefault.save();
      }
    }
    
    await address.destroy();
    
    res.json({
      success: true,
      message: '成功删除地址'
    });
  } catch (error) {
    next(error);
  }
});

export default router;