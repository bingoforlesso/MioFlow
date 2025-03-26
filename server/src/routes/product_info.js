import express from 'express';
import { ProductInfo } from '../models/product.js';
import { Op } from 'sequelize';
import auth from '../middleware/auth.js';
import sequelize from '../config/database.js';

const router = express.Router();

/**
 * @swagger
 * /api/v1/products:
 *   get:
 *     summary: 获取产品列表
 *     tags: [产品管理]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *         description: 返回结果数量限制
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: 页码
 *       - in: query
 *         name: brand
 *         schema:
 *           type: string
 *         description: 按品牌筛选
 *       - in: query
 *         name: material
 *         schema:
 *           type: string
 *         description: 按材质筛选
 *     responses:
 *       200:
 *         description: 成功获取产品列表
 */
router.get('/', async (req, res, next) => {
  try {
    const { 
      limit = 100, 
      page = 1, 
      brand, 
      material, 
      color, 
      specification, 
      product_type 
    } = req.query;
    
    // 构建查询条件
    const whereClause = {};
    if (brand) whereClause.brand = brand;
    if (material) whereClause.material = material;
    if (color) whereClause.color = color;
    if (specification) whereClause.specification = specification;
    if (product_type) whereClause.product_type = product_type;
    
    // 分页
    const offset = (page - 1) * limit;
    
    // 获取产品总数
    const count = await ProductInfo.count({
      where: whereClause
    });
    
    // 获取产品列表
    const products = await ProductInfo.findAll({
      where: whereClause,
      limit: parseInt(limit),
      offset: offset
    });
    
    res.json({
      success: true,
      data: {
        total: count,
        page: parseInt(page),
        page_size: parseInt(limit),
        total_pages: Math.ceil(count / limit),
        products: products
      }
    });
  } catch (error) {
    console.error('获取产品信息失败:', error);
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/products/search:
 *   post:
 *     summary: 搜索产品
 *     tags: [产品管理]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               query:
 *                 type: string
 *                 description: 搜索关键词
 *               params:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: 附加搜索参数
 *               page:
 *                 type: integer
 *                 default: 1
 *               page_size:
 *                 type: integer
 *                 default: 20
 *               filters:
 *                 type: object
 *                 description: 筛选条件
 *     responses:
 *       200:
 *         description: 搜索结果
 */
router.post('/search', async (req, res, next) => {
  try {
    const { query, params, page = 1, page_size = 20, filters = {} } = req.body;
    console.log('搜索请求:', { query, params, page, page_size, filters });
    
    let whereClause = {};
    
    // 基本搜索条件
    if (query) {
      // 替换度为°以匹配数据库格式
      const normalizedQuery = query.replace('度', '°');
      
      whereClause = {
        [Op.or]: [
          { name: { [Op.like]: `%${normalizedQuery}%` } },
          { product_name: { [Op.like]: `%${normalizedQuery}%` } },
          { specification: { [Op.like]: `%${normalizedQuery}%` } },
          { brand: { [Op.like]: `%${normalizedQuery}%` } },
          { material: { [Op.like]: `%${normalizedQuery}%` } }
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
    
    // 添加筛选条件
    if (filters && Object.keys(filters).length > 0) {
      const filterConditions = {};
      
      Object.keys(filters).forEach(key => {
        if (filters[key] && filters[key].length > 0) {
          filterConditions[key] = { [Op.in]: filters[key] };
        }
      });
      
      if (Object.keys(filterConditions).length > 0) {
        whereClause = {
          ...whereClause,
          ...filterConditions
        };
      }
    }
    
    // 计算分页
    const offset = (page - 1) * page_size;
    
    // 获取总数
    const total = await ProductInfo.count({
      where: whereClause
    });
    
    // 获取产品列表
    const products = await ProductInfo.findAll({
      where: whereClause,
      limit: page_size,
      offset: offset
    });
    
    // 获取筛选属性统计
    const filterAttributes = ['brand', 'material', 'specification', 'color', 'model'];
    const availableFilters = {};
    
    for (const attr of filterAttributes) {
      const attrValues = await ProductInfo.findAll({
        attributes: [attr, [sequelize.fn('COUNT', sequelize.col(attr)), 'count']],
        where: whereClause,
        group: [attr],
        having: sequelize.where(sequelize.col(attr), {[Op.ne]: null}),
        raw: true
      });
      
      availableFilters[attr] = attrValues.map(item => ({
        value: item[attr],
        count: parseInt(item.count)
      }));
    }
    
    console.log(`找到 ${products.length} 个产品，总数: ${total}`);
    
    res.json({
      success: true,
      message: "产品搜索成功",
      data: products,
      meta: {
        total,
        page,
        page_size,
        total_pages: Math.ceil(total / page_size)
      },
      filters: availableFilters
    });
  } catch (error) {
    console.error('搜索产品失败:', error);
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/products/attributes/{attribute}:
 *   get:
 *     summary: 获取产品属性值列表
 *     tags: [产品管理]
 *     parameters:
 *       - in: path
 *         name: attribute
 *         required: true
 *         schema:
 *           type: string
 *         description: 属性名称 (brand, material, specification等)
 *     responses:
 *       200:
 *         description: 属性值列表
 */
router.get('/attributes/:attribute', async (req, res, next) => {
  try {
    const { attribute } = req.params;
    
    // 检查属性是否有效
    const validAttributes = ['brand', 'material', 'specification', 'color', 'model', 'product_type'];
    if (!validAttributes.includes(attribute)) {
      return res.status(400).json({
        success: false,
        error: {
          message: '无效的属性名称'
        }
      });
    }
    
    // 获取属性值列表
    const attributeValues = await ProductInfo.findAll({
      attributes: [attribute, [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      where: {
        [attribute]: {
          [Op.ne]: null
        }
      },
      group: [attribute],
      order: [[sequelize.literal('count'), 'DESC']],
      raw: true
    });
    
    res.json({
      success: true,
      data: attributeValues.map(item => ({
        value: item[attribute],
        count: parseInt(item.count)
      }))
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/products/{id}:
 *   get:
 *     summary: 获取产品详情
 *     tags: [产品管理]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 产品ID
 *     responses:
 *       200:
 *         description: 产品详情
 *       404:
 *         description: 产品不存在
 */
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

/**
 * @swagger
 * /api/v1/products/category/{type}:
 *   get:
 *     summary: 根据产品类型获取产品列表
 *     tags: [产品管理]
 *     parameters:
 *       - in: path
 *         name: type
 *         required: true
 *         schema:
 *           type: string
 *         description: 产品类型
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *         description: 返回结果数量限制
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: 页码
 *     responses:
 *       200:
 *         description: 产品列表
 */
router.get('/category/:type', async (req, res, next) => {
  try {
    const { type } = req.params;
    const { limit = 100, page = 1 } = req.query;
    
    // 计算分页
    const offset = (page - 1) * limit;
    
    // 获取产品总数
    const count = await ProductInfo.count({
      where: {
        product_type: type
      }
    });
    
    // 获取产品列表
    const products = await ProductInfo.findAll({
      where: {
        product_type: type
      },
      limit: parseInt(limit),
      offset: offset
    });
    
    res.json({
      success: true,
      data: {
        total: count,
        page: parseInt(page),
        page_size: parseInt(limit),
        total_pages: Math.ceil(count / limit),
        products: products
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/products/brand/{brand}:
 *   get:
 *     summary: 根据品牌获取产品列表
 *     tags: [产品管理]
 *     parameters:
 *       - in: path
 *         name: brand
 *         required: true
 *         schema:
 *           type: string
 *         description: 品牌名称
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *         description: 返回结果数量限制
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: 页码
 *     responses:
 *       200:
 *         description: 产品列表
 */
router.get('/brand/:brand', async (req, res, next) => {
  try {
    const { brand } = req.params;
    const { limit = 100, page = 1 } = req.query;
    
    // 计算分页
    const offset = (page - 1) * limit;
    
    // 获取产品总数
    const count = await ProductInfo.count({
      where: {
        brand: brand
      }
    });
    
    // 获取产品列表
    const products = await ProductInfo.findAll({
      where: {
        brand: brand
      },
      limit: parseInt(limit),
      offset: offset
    });
    
    res.json({
      success: true,
      data: {
        total: count,
        page: parseInt(page),
        page_size: parseInt(limit),
        total_pages: Math.ceil(count / limit),
        products: products
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/products/similar/{id}:
 *   get:
 *     summary: 获取相似产品
 *     tags: [产品管理]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: 产品ID
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: 返回结果数量限制
 *     responses:
 *       200:
 *         description: 相似产品列表
 *       404:
 *         description: 产品不存在
 */
router.get('/similar/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { limit = 10 } = req.query;
    
    // 获取原产品
    const originalProduct = await ProductInfo.findByPk(id);
    if (!originalProduct) {
      return res.status(404).json({
        success: false,
        error: {
          message: '产品不存在'
        }
      });
    }
    
    // 根据产品类型、品牌、材质等查找相似产品
    const similarProducts = await ProductInfo.findAll({
      where: {
        id: { [Op.ne]: id }, // 排除当前产品
        [Op.or]: [
          // 相同品牌和类型的产品
          {
            [Op.and]: [
              { brand: originalProduct.brand },
              { product_type: originalProduct.product_type }
            ]
          },
          // 相同材质和类型的产品
          {
            [Op.and]: [
              { material: originalProduct.material },
              { product_type: originalProduct.product_type }
            ]
          }
        ]
      },
      limit: parseInt(limit)
    });
    
    res.json({
      success: true,
      data: similarProducts
    });
  } catch (error) {
    next(error);
  }
});

export default router;