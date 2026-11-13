const express = require('express');
const router = express.Router();
const db = require('../database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

function getTodayDateString() {
  const d = new Date();
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// GET /api/admin/dashboard - Attendance statistics
router.get('/dashboard', authenticateToken, requireAdmin, (req, res) => {
  try {
    const today = getTodayDateString();

    // Total employees count
    const totalRow = db.prepare(
      "SELECT COUNT(*) as count FROM users WHERE role = 'employee'"
    ).get();
    const totalEmployees = totalRow.count;

    // Present today (has check_in)
    const presentRow = db.prepare(
      "SELECT COUNT(*) as count FROM attendance WHERE date = ? AND check_in IS NOT NULL"
    ).get(today);
    const present = presentRow.count;

    // Late today
    const lateRow = db.prepare(
      "SELECT COUNT(*) as count FROM attendance WHERE date = ? AND status = 'late'"
    ).get(today);
    const late = lateRow.count;

    // Absent today (total employees - present)
    const absent = Math.max(0, totalEmployees - present);

    // Active session
    const activeSession = db.prepare(
      'SELECT * FROM sessions WHERE is_active = 1 ORDER BY id DESC LIMIT 1'
    ).get();

    let sessionData = null;
    if (activeSession) {
      const now = new Date();
      const expiresAt = new Date(activeSession.expires_at);
      const isExpired = now.getTime() > expiresAt.getTime();
      sessionData = {
        sessionId: activeSession.session_id,
        qrToken: activeSession.qr_token,
        validityMinutes: activeSession.validity_minutes,
        createdAt: activeSession.created_at,
        expiresAt: activeSession.expires_at,
        isExpired,
        remainingSeconds: Math.max(0, Math.floor((expiresAt.getTime() - now.getTime()) / 1000))
      };
    }

    return res.json({
      success: true,
      data: {
        today,
        totalEmployees,
        present,
        absent,
        late,
        activeSession: sessionData
      }
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch admin dashboard statistics'
    });
  }
});

// GET /api/admin/employees - List of all employees
router.get('/employees', authenticateToken, requireAdmin, (req, res) => {
  try {
    const employees = db.prepare(`
      SELECT id, name, email, role, department, created_at 
      FROM users 
      WHERE role = 'employee' 
      ORDER BY id ASC
    `).all();

    return res.json({
      success: true,
      data: employees
    });
  } catch (error) {
    console.error('Admin employees error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve employees'
    });
  }
});

// GET /api/admin/attendance - All attendance records
router.get('/attendance', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { date, userId } = req.query;

    let query = `
      SELECT 
        a.id,
        a.user_id,
        u.name as employee_name,
        u.email as employee_email,
        u.department,
        a.session_id,
        a.date,
        a.check_in,
        a.check_out,
        a.latitude_in,
        a.longitude_in,
        a.latitude_out,
        a.longitude_out,
        a.status,
        a.created_at
      FROM attendance a
      JOIN users u ON a.user_id = u.id
      WHERE 1=1
    `;
    const params = [];

    if (date) {
      query += ' AND a.date = ?';
      params.push(date);
    }

    if (userId) {
      query += ' AND a.user_id = ?';
      params.push(userId);
    }

    query += ' ORDER BY a.date DESC, a.id DESC LIMIT 100';

    const records = db.prepare(query).all(...params);

    return res.json({
      success: true,
      data: records
    });
  } catch (error) {
    console.error('Admin attendance error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve attendance records'
    });
  }
});

// GET /api/admin/attendance/:id - Individual attendance details
router.get('/attendance/:id', authenticateToken, requireAdmin, (req, res) => {
  try {
    const record = db.prepare(`
      SELECT 
        a.*,
        u.name as employee_name,
        u.email as employee_email,
        u.department
      FROM attendance a
      JOIN users u ON a.user_id = u.id
      WHERE a.id = ?
    `).get(req.params.id);

    if (!record) {
      return res.status(404).json({
        success: false,
        message: 'Attendance record not found'
      });
    }

    return res.json({
      success: true,
      data: record
    });
  } catch (error) {
    console.error('Admin attendance by id error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve attendance record'
    });
  }
});

module.exports = router;

