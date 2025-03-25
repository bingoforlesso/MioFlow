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

// Login route
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

// Check if phone is registered
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

// Get current user
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

export default router; 