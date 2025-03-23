import express from 'express';
import { AuthService } from '../services/AuthService';
import { authMiddleware } from '../middleware/auth';

const router = express.Router();
const authService = new AuthService();

// 注册
router.post('/register', async (req, res) => {
  try {
    const { username, password, phone, companyName } = req.body;
    const result = await authService.register(username, password, phone, companyName);
    res.json(result);
  } catch (error) {
    res.status(400).json({
      error: '注册失败',
      message: error.message
    });
  }
});

// 登录
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const result = await authService.login(username, password);
    res.json(result);
  } catch (error) {
    res.status(401).json({
      error: '登录失败',
      message: error.message
    });
  }
});

// 登出
router.post('/logout', authMiddleware, async (req: any, res) => {
  try {
    await authService.logout(req.user.userId);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({
      error: '登出失败',
      message: error.message
    });
  }
});

// 修改密码
router.post('/change-password', authMiddleware, async (req: any, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    await authService.changePassword(req.user.userId, oldPassword, newPassword);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({
      error: '修改密码失败',
      message: error.message
    });
  }
});

// 获取用户信息
router.get('/profile', authMiddleware, async (req: any, res) => {
  try {
    const profile = await authService.getUserProfile(req.user.userId);
    res.json(profile);
  } catch (error) {
    res.status(404).json({
      error: '获取用户信息失败',
      message: error.message
    });
  }
});

export default router;