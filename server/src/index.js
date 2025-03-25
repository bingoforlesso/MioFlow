import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import sequelize from './config/database.js';
import authRoutes from './routes/auth.js';
import productRoutes from './routes/product.js';
import productInfoRoutes from './routes/product_info.js';
import orderRouter from './routes/order.js';
import { errorHandler } from './middleware/error.js';
import { seedProducts } from './seeders/products.js';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// CORS configuration
const corsOptions = {
  origin: '*', // 允许所有来源
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

// Routes
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/product_info', productInfoRoutes);
app.use('/api/v1/orders', orderRouter);

// Error handling
app.use(errorHandler);

// Test database connection and start server
async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('数据库连接成功');
    
    // 同步数据库模型，但不强制重置表
    await sequelize.sync({ force: false });
    console.log('数据库模型同步完成');
    
    // 不再导入测试数据
    // await seedProducts();
    // console.log('测试数据导入完成');
    
    app.listen(port, () => {
      console.log(`服务器运行在 http://localhost:${port}`);
    });
  } catch (error) {
    console.error('服务器启动错误:', error);
    process.exit(1);
  }
}

startServer();