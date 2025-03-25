import express from 'express';
import Product from '../models/product.js';
import { Op } from 'sequelize';

const router = express.Router();

// 获取产品列表
router.get('/', async (req, res, next) => {
  try {
    const products = await Product.findAll();
    const formattedProducts = products.map(product => {
      const data = product.toJSON();
      data.price = Number(data.price);
      return data;
    });
    res.json({
      success: true,
      data: formattedProducts
    });
  } catch (error) {
    next(error);
  }
});

// 搜索产品
router.post('/search', async (req, res, next) => {
  try {
    const { query, params } = req.body;
    console.log('Search request:', { query, params });
    
    let whereClause = {};
    
    if (query) {
      whereClause = {
        [Op.or]: [
          { name: { [Op.like]: `%${query}%` } },
          { description: { [Op.like]: `%${query}%` } },
          { code: { [Op.like]: `%${query}%` } }
        ]
      };
    }

    // 基本搜索，不考虑复杂JSON属性
    const products = await Product.findAll({
      where: whereClause
    });

    console.log(`Found ${products.length} products with basic search`);

    // 如果有params参数，则手动过滤包含这些属性的产品
    let filteredProducts = [...products];
    if (params && params.length > 0) {
      filteredProducts = products.filter(product => {
        if (!product.attributes) return false;
        
        // 解析JSON属性（如果已经是对象就直接使用）
        const attrs = typeof product.attributes === 'string' 
          ? JSON.parse(product.attributes) 
          : product.attributes;
        
        // 检查每个参数是否匹配产品的任何属性（key或值）
        return params.every(param => {
          // 搜索所有属性键和值
          for (const [key, values] of Object.entries(attrs)) {
            // 检查键是否匹配
            if (key.toLowerCase().includes(param.toLowerCase())) {
              return true;
            }
            
            // 检查值是否匹配
            if (Array.isArray(values)) {
              for (const value of values) {
                if (String(value).toLowerCase().includes(param.toLowerCase())) {
                  return true;
                }
              }
            }
          }
          
          return false; // 此参数未匹配任何属性
        });
      });
    }

    console.log(`Found ${filteredProducts.length} products after filtering attributes`);

    const formattedProducts = filteredProducts.map(product => {
      const data = product.toJSON();
      data.price = Number(data.price);
      return data;
    });

    res.json({
      success: true,
      data: formattedProducts
    });
  } catch (error) {
    console.error('Search error:', error);
    next(error);
  }
});

// 通过商品代码获取产品
router.get('/code/:code', async (req, res, next) => {
  try {
    const product = await Product.findOne({
      where: { code: req.params.code }
    });
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    const data = product.toJSON();
    data.price = Number(data.price);
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    next(error);
  }
});

// 获取单个产品详情
router.get('/:id', async (req, res, next) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    const data = product.toJSON();
    data.price = Number(data.price);
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    next(error);
  }
});

// 创建新产品
router.post('/', async (req, res, next) => {
  try {
    const product = await Product.create(req.body);
    res.status(201).json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
});

// 更新产品
router.put('/:id', async (req, res, next) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    await product.update(req.body);
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
});

// 删除产品
router.delete('/:id', async (req, res, next) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    await product.destroy();
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});

export default router; 