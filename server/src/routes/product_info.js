import express from 'express';
import { ProductInfo } from '../models/product.js';
import { Op } from 'sequelize';

const router = express.Router();

// 获取所有产品信息
router.get('/', async (req, res, next) => {
  try {
    const products = await ProductInfo.findAll({
      limit: req.query.limit ? parseInt(req.query.limit) : 100
    });
    res.json({
      success: true,
      data: products
    });
  } catch (error) {
    console.error('获取产品信息失败:', error);
    next(error);
  }
});

// 搜索产品信息
router.post('/search', async (req, res, next) => {
  try {
    const { query, params } = req.body;
    console.log('搜索请求:', { query, params });
    
    let whereClause = {};
    
    if (query) {
      // 替换度为°以匹配数据库格式
      const normalizedQuery = query.replace('度', '°');
      
      whereClause = {
        [Op.or]: [
          { name: { [Op.like]: `%${normalizedQuery}%` } },
          { product_name: { [Op.like]: `%${normalizedQuery}%` } },
          { specification: { [Op.like]: `%${normalizedQuery}%` } }
        ]
      };
      
      // 特殊处理45度弯头的搜索
      if (normalizedQuery.includes('45') && normalizedQuery.includes('弯头')) {
        whereClause = {
          [Op.and]: [
            { name: { [Op.like]: '%45%' } },
            { name: { [Op.like]: '%弯头%' } }
          ]
        };
      }
    }
    
    // 添加参数过滤
    if (params && params.length > 0) {
      const paramConditions = params.map(param => ({
        [Op.or]: [
          { name: { [Op.like]: `%${param}%` } },
          { specification: { [Op.like]: `%${param}%` } },
          { material: { [Op.like]: `%${param}%` } },
          { color: { [Op.like]: `%${param}%` } },
          { degree: { [Op.like]: `%${param}%` } }
        ]
      }));
      
      if (Object.keys(whereClause).length > 0) {
        whereClause = {
          [Op.and]: [whereClause, ...paramConditions]
        };
      } else {
        whereClause = {
          [Op.and]: paramConditions
        };
      }
    }
    
    const products = await ProductInfo.findAll({
      where: whereClause,
      limit: 100
    });
    
    console.log(`找到 ${products.length} 个产品`);
    
    res.json({
      success: true,
      data: products
    });
  } catch (error) {
    console.error('搜索产品失败:', error);
    next(error);
  }
});

// 通过ID获取产品
router.get('/:id', async (req, res, next) => {
  try {
    const product = await ProductInfo.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
});

export default router; 