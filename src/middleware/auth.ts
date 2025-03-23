import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/AuthService';

const authService = new AuthService();

export interface AuthRequest extends Request {
  user?: {
    userId: string;
  };
}

export const authMiddleware = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      throw new Error('未提供认证token');
    }

    const decoded = await authService.verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({
      error: '认证失败',
      message: error.message
    });
  }
};

// 可选的认证中间件，用于某些可以匿名访问的接口
export const optionalAuthMiddleware = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (token) {
      const decoded = await authService.verifyToken(token);
      req.user = decoded;
    }
    next();
  } catch (error) {
    // 即使认证失败也继续
    next();
  }
};