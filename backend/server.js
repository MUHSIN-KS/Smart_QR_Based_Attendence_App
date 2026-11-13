const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const attendanceRoutes = require('./routes/attendance');
const adminRoutes = require('./routes/admin');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable Cross-Origin Resource Sharing
app.use(cors());

// Parse JSON request body
app.use(express.json());

// Request logger for debugging assessment workflows
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Smart QR-Based Attendance Management System API',
    version: '1.0.0',
    status: 'online',
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: ['POST /api/auth/login', 'POST /api/auth/register', 'GET /api/auth/profile'],
      attendance: [
        'POST /api/attendance/session',
        'GET /api/attendance/session/active',
        'POST /api/attendance/check-in',
        'POST /api/attendance/check-out',
        'GET /api/attendance/today',
        'GET /api/attendance/history'
      ],
      admin: [
        'GET /api/admin/dashboard',
        'GET /api/admin/employees',
        'GET /api/admin/attendance',
        'GET /api/admin/attendance/:id'
      ]
    }
  });
});

// Route modules
app.use('/api/auth', authRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} not found`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

// Start listening
app.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 Smart QR Attendance API Server is running!`);
  console.log(`📡 Local URL: http://localhost:${PORT}`);
  console.log(`📱 Android Emulator URL: http://10.0.2.2:${PORT}`);
  console.log(`====================================================`);
});

