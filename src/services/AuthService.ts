import { db } from '../utils/db';
import { cache } from '../utils/cache';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const TOKEN_EXPIRE = 60 * 60 * 24 * 7; // 7 days

export class AuthService {
  async register(username: string, password: string, phone: string, companyName?: string) {
    // 检查用户是否已存在
    const existingUser = await db.query(
      'SELECT id FROM user WHERE username = ? OR phone = ?',
      [username, phone]
    );

    if (existingUser.length > 0) {
      throw new Error('用户名或手机号已存在');
    }

    // 加密密码
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 生成用户ID
    const userId = `U${Date.now()}${Math.random().toString(36).substr(2, 5)}`;

    // 创建用户
    await db.execute(
      'INSERT INTO user (id, username, encrypted_password, phone, company_name) VALUES (?, ?, ?, ?, ?)',
      [userId, username, hashedPassword, phone, companyName]
    );

    return { userId };
  }

  async login(username: string, password: string) {
    // 查找用户
    const [user] = await db.query(
      'SELECT id, encrypted_password FROM user WHERE username = ?',
      [username]
    );

    if (!user) {
      throw new Error('用户不存在');
    }

    // 验证密码
    const isValid = await bcrypt.compare(password, user.encrypted_password);
    if (!isValid) {
      throw new Error('密码错误');
    }

    // 生成 JWT token
    const token = jwt.sign({ userId: user.id }, JWT_SECRET, {
      expiresIn: TOKEN_EXPIRE
    });

    // 缓存token
    await cache.set(`auth:${user.id}`, token, TOKEN_EXPIRE);

    return {
      userId: user.id,
      token
    };
  }

  async verifyToken(token: string) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as { userId: string };
      
      // 验证缓存中的token
      const cachedToken = await cache.get(`auth:${decoded.userId}`);
      if (cachedToken !== token) {
        throw new Error('Token已失效');
      }

      return decoded;
    } catch (error) {
      throw new Error('无效的token');
    }
  }

  async logout(userId: string) {
    // 从缓存中删除token
    await cache.del(`auth:${userId}`);
    return true;
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    // 查找用户
    const [user] = await db.query(
      'SELECT encrypted_password FROM user WHERE id = ?',
      [userId]
    );

    if (!user) {
      throw new Error('用户不存在');
    }

    // 验证旧密码
    const isValid = await bcrypt.compare(oldPassword, user.encrypted_password);
    if (!isValid) {
      throw new Error('原密码错误');
    }

    // 加密新密码
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 更新密码
    await db.execute(
      'UPDATE user SET encrypted_password = ? WHERE id = ?',
      [hashedPassword, userId]
    );

    // 使当前token失效
    await this.logout(userId);

    return true;
  }

  async getUserProfile(userId: string) {
    const [user] = await db.query(
      'SELECT id, username, phone, company_name, created_at FROM user WHERE id = ?',
      [userId]
    );

    if (!user) {
      throw new Error('用户不存在');
    }

    return user;
  }
}