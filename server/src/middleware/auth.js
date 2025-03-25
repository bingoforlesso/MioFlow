import jwt from 'jsonwebtoken';

const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          message: '未提供认证令牌'
        }
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    
    req.user = {
      id: decoded.id
    };
    
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: {
        message: '无效的认证令牌'
      }
    });
  }
};

export default auth; 