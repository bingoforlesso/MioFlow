import express from 'express';
import { DialogEngine } from '../services/DialogEngine';

const router = express.Router();
const dialogEngine = new DialogEngine();

router.post('/parse', async (req, res) => {
  try {
    const { text } = req.body;
    const result = await dialogEngine.processUserInput(text);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      error: '对话处理失败',
      message: error.message
    });
  }
});

export default router;