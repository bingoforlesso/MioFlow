import express from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Sequelize } from 'sequelize';
import initUserModel from '../models/user.js';

const router = express.Router();

// Initialize Sequelize and User model
const sequelize = new Sequelize({
  dialect: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  username: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Ac661978',
  database: process.env.DB_NAME || 'mioflow',
  logging: false
});

const User = initUserModel(sequelize);

/**
 * @swagger
 * /api/v1/auth/register:
 *   post:
 *     summary: 用户注册
 *     tags: [用户认证]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - phone
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 example: "张三"
 *               phone:
 *                 type: string
 *                 example: "13800138000"
 *               password:
 *                 type: string
 *                 example: "password123"
 *               company_name:
 *                 type: string
 *                 example: "XX贸易有限公司"
 *     responses:
 *       201:
 *         description: 注册成功
 *       400:
 *         description: 无效的请求或手机号/用户名已被使用
 */
router.post('/register', async (req, res, next) => {
  try {
    const { username, phone, password, company_name } = req.body;

    // 验证输入
    if (!username || !phone || !password) {
      return res.status(400).json({
        success: false,
        error: {
          message: '请提供用户名、手机号和密码'
        }
      });
    }

    // 检查手机号是否已注册
    const existingUser = await User.findOne({
      where: {
        phone: phone
      }
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: {
          message: '该手机号已被注册'
        }
      });
    }

    // 检查用户名是否已存在
    const existingUsername = await User.findOne({
      where: {
        username: username
      }
    });

    if (existingUsername) {
      return res.status(400).json({
        success: false,
        error: {
          message: '该用户名已被使用'
        }
      });
    }

    // 创建用户
    const newUser = await User.create({
      username,
      phone,
      encrypted_password: password, // 钩子将自动加密
      company_name: company_name || null
    });

    // 生成JWT令牌
    const token = jwt.sign(
      { id: newUser.id },
      process.env.JWT_SECRET || 'your-jwt-secret-key',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // 返回用户信息和令牌
    res.status(201).json({
      success: true,
      data: {
        token,
        user: {
          id: newUser.id,
          username: newUser.username,
          phone: newUser.phone,
          company_name: newUser.company_name
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: 用户登录
 *     tags: [用户认证]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - password
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "13800138000"
 *               password:
 *                 type: string
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: 登录成功
 *       401:
 *         description: 无效的凭证
 */
router.post('/login', async (req, res, next) => {
  try {
    const { phone, password } = req.body;

    // Validate input
    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Please provide both phone and password'
        }
      });
    }

    // Find user by phone
    const user = await User.findOne({
      where: {
        phone: phone
      }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid credentials'
        }
      });
    }

    // Check password
    const hashedPassword = crypto.createHash('md5').update(password).digest('hex');
    if (user.encrypted_password !== hashedPassword) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid credentials'
        }
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET || 'your-jwt-secret-key',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          username: user.username,
          phone: user.phone,
          company_name: user.company_name
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/auth/check-phone/{phone}:
 *   get:
 *     summary: 检查手机号是否已注册
 *     tags: [用户认证]
 *     parameters:
 *       - name: phone
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: 成功检查
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     exists:
 *                       type: boolean
 *                       example: false
 */
router.get('/check-phone/:phone', async (req, res, next) => {
  try {
    const { phone } = req.params;
    const user = await User.findOne({
      where: {
        phone: phone
      }
    });

    res.json({
      success: true,
      data: {
        exists: !!user
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/auth/me:
 *   get:
 *     summary: 获取当前用户信息
 *     tags: [用户认证]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 成功获取用户信息
 *       401:
 *         description: 未授权或令牌无效
 *       404:
 *         description: 用户不存在
 */
router.get('/me', async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'No token provided'
        }
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-jwt-secret-key');
    const user = await User.findByPk(decoded.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: {
          message: 'User not found'
        }
      });
    }

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          phone: user.phone,
          company_name: user.company_name
        }
      }
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid token'
        }
      });
    }
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/auth/reset-password:
 *   post:
 *     summary: 重置密码
 *     tags: [用户认证]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - new_password
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "13800138000"
 *               verification_code:
 *                 type: string
 *                 example: "123456"
 *               new_password:
 *                 type: string
 *                 example: "newpassword123"
 *     responses:
 *       200:
 *         description: 密码重置成功
 *       400:
 *         description: 无效的请求
 *       404:
 *         description: 用户不存在
 */
router.post('/reset-password', async (req, res, next) => {
  try {
    const { phone, verification_code, new_password } = req.body;

    // 这里通常需要验证验证码，但为了示例我们直接进行下一步
    // 在实际应用中需要实现验证码验证逻辑

    // 验证输入
    if (!phone || !new_password) {
      return res.status(400).json({
        success: false,
        error: {
          message: '请提供手机号和新密码'
        }
      });
    }

    // 查找用户
    const user = await User.findOne({
      where: {
        phone: phone
      }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: {
          message: '用户不存在'
        }
      });
    }

    // 更新密码
    user.encrypted_password = new_password; // 钩子将自动加密
    await user.save();

    res.json({
      success: true,
      message: '密码重置成功'
    });
  } catch (error) {
    next(error);
  }
});

export default router;