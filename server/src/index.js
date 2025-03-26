import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import sequelize from './config/database.js';
import authRoutes from './routes/auth.js';
import productInfoRoutes from './routes/product_info.js';
import orderRouter from './routes/order.js';
import cartRouter from './routes/cart.js';
import dealerRouter from './routes/dealer.js';
import addressRouter from './routes/address.js';
import { errorHandler } from './middleware/error.js';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

// Load environment variables
dotenv.config();

const app = express();
// 将端口改回3000
const port = 3000;

// Swagger文档选项
const swaggerOptions = {
  definition: {
    openapi: '3.1.0',
    info: {
      title: 'MioFlow API',
      version: '1.0.1',
      description: 'MioFlow 后端 API 服务',
    },
    servers: [
      {
        url: `http://localhost:${port}`,
        description: '开发服务器',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    tags: [
      {
        name: '用户认证',
        description: '用户注册、登录和认证相关接口'
      },
      {
        name: '产品管理',
        description: '产品信息查询和搜索接口'
      },
      {
        name: '购物车',
        description: '购物车管理接口'
      },
      {
        name: '订单管理',
        description: '订单创建和查询接口'
      },
      {
        name: '经销商管理',
        description: '经销商信息相关接口'
      },
      {
        name: '地址管理',
        description: '收货地址相关接口'
      }
    ]
  },
  apis: ['./src/routes/*.js'], // 扫描路由文件生成API文档
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// CORS configuration
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 200
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Swagger文档
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get('/openapi.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Routes
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/products', productInfoRoutes);
app.use('/api/v1/orders', orderRouter);
app.use('/api/v1/cart', cartRouter);
app.use('/api/v1/dealers', dealerRouter);
app.use('/api/v1/addresses', addressRouter);

// Error handling
app.use(errorHandler);

// Test database connection and start server
async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('数据库连接成功');
    
    await sequelize.sync({ force: false });
    console.log('数据库模型同步完成');
    
    app.listen(port, '0.0.0.0', () => {
      console.log(`服务器运行在 http://0.0.0.0:${port}`);
      console.log(`API文档访问地址: http://localhost:${port}/docs`);
    });
  } catch (error) {
    console.error('服务器启动错误:', error);
    process.exit(1);
  }
}

startServer();