import express from 'express';
import cors from 'cors';
import dialogRouter from './api/dialog';
import cartRouter from './api/cart';
import orderRouter from './api/order';

const app = express();

// 中间件
app.use(cors());
app.use(express.json());

// 路由
app.use('/api/dialog', dialogRouter);
app.use('/api/cart', cartRouter);
app.use('/api/order', orderRouter);

// 错误处理
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    error: '服务器内部错误',
    message: err.message
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});