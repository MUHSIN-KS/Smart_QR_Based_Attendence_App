const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'smart_qr_attendance_jwt_super_secret_key_2026';

function generateToken(user) {
  return jwt.sign(
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      department: user.department
    },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized: Missing or invalid authentication token'
    });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: Token is expired or invalid'
      });
    }
    req.user = user;
    next();
  });
}

function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Forbidden: Admin access required'
    });
  }
  next();
}

module.exports = {
  JWT_SECRET,
  generateToken,
  authenticateToken,
  requireAdmin
};

