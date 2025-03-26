import express from 'express';
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// 定义经销商模型
const Dealer = sequelize.define('Dealer', {
  id: {
    type: DataTypes.STRING,
    primaryKey: true,
    defaultValue: () => `D${Date.now()}`
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  contact_person: {
    type: DataTypes.STRING,
    allowNull: true
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: true
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true
  },
  province: {
    type: DataTypes.STRING,
    allowNull: true
  },
  city: {
    type: DataTypes.STRING,
    allowNull: true
  },
  district: {
    type: DataTypes.STRING,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active'
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'dealers'
});

// 同步模型
sequelize.sync();

/**
 * @swagger
 * /api/v1/dealers:
 *   get:
 *     summary: 获取所有经销商列表
 *     tags: [经销商管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: city
 *         schema:
 *           type: string
 *         description: 按城市筛选
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [active, inactive]
 *         description: 按状态筛选
 *     responses:
 *       200:
 *         description: 成功获取经销商列表
 */
router.get('/', auth, async (req, res, next) => {
  try {
    const { city, status } = req.query;
    const whereClause = {};
    
    if (city) {
      whereClause.city = city;
    }
    
    if (status) {
      whereClause.status = status;
    }
    
    const dealers = await Dealer.findAll({
      where: whereClause,
      order: [['created_at', 'DESC']]
    });
    
    res.json({
      success: true,
      data: dealers
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/dealers/{id}:
 *   get:
 *     summary: 获取单个经销商详情
 *     tags: [经销商管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 经销商ID
 *     responses:
 *       200:
 *         description: 成功获取经销商详情
 *       404:
 *         description: 经销商不存在
 */
router.get('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    const dealer = await Dealer.findByPk(id);
    
    if (!dealer) {
      return res.status(404).json({
        success: false,
        error: {
          message: '经销商不存在'
        }
      });
    }
    
    res.json({
      success: true,
      data: dealer
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/dealers:
 *   post:
 *     summary: 创建新经销商
 *     tags: [经销商管理]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 example: "某某经销商"
 *               contact_person:
 *                 type: string
 *                 example: "张三"
 *               phone:
 *                 type: string
 *                 example: "13800138000"
 *               address:
 *                 type: string
 *                 example: "某某街道某某号"
 *               province:
 *                 type: string
 *                 example: "广东省"
 *               city:
 *                 type: string
 *                 example: "深圳市"
 *               district:
 *                 type: string
 *                 example: "南山区"
 *     responses:
 *       201:
 *         description: 成功创建经销商
 *       400:
 *         description: 无效请求
 */
router.post('/', auth, async (req, res, next) => {
  try {
    const { name, contact_person, phone, address, province, city, district } = req.body;
    
    if (!name) {
      return res.status(400).json({
        success: false,
        error: {
          message: '经销商名称不能为空'
        }
      });
    }
    
    const dealer = await Dealer.create({
      name,
      contact_person,
      phone,
      address,
      province,
      city,
      district
    });
    
    res.status(201).json({
      success: true,
      data: dealer
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/dealers/{id}:
 *   put:
 *     summary: 更新经销商信息
 *     tags: [经销商管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 经销商ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               contact_person:
 *                 type: string
 *               phone:
 *                 type: string
 *               address:
 *                 type: string
 *               province:
 *                 type: string
 *               city:
 *                 type: string
 *               district:
 *                 type: string
 *               status:
 *                 type: string
 *                 enum: [active, inactive]
 *     responses:
 *       200:
 *         description: 成功更新经销商信息
 *       404:
 *         description: 经销商不存在
 */
router.put('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, contact_person, phone, address, province, city, district, status } = req.body;
    
    const dealer = await Dealer.findByPk(id);
    
    if (!dealer) {
      return res.status(404).json({
        success: false,
        error: {
          message: '经销商不存在'
        }
      });
    }
    
    if (name) dealer.name = name;
    if (contact_person) dealer.contact_person = contact_person;
    if (phone) dealer.phone = phone;
    if (address) dealer.address = address;
    if (province) dealer.province = province;
    if (city) dealer.city = city;
    if (district) dealer.district = district;
    if (status && ['active', 'inactive'].includes(status)) dealer.status = status;
    
    await dealer.save();
    
    res.json({
      success: true,
      data: dealer
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/dealers/{id}:
 *   delete:
 *     summary: 删除经销商
 *     tags: [经销商管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 经销商ID
 *     responses:
 *       200:
 *         description: 成功删除经销商
 *       404:
 *         description: 经销商不存在
 */
router.delete('/:id', auth, async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const dealer = await Dealer.findByPk(id);
    
    if (!dealer) {
      return res.status(404).json({
        success: false,
        error: {
          message: '经销商不存在'
        }
      });
    }
    
    await dealer.destroy();
    
    res.json({
      success: true,
      message: '成功删除经销商'
    });
  } catch (error) {
    next(error);
  }
});

export default router;