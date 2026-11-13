const express = require('express');
const router = express.Router();
const crypto = require('node:crypto');
const db = require('../database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Helper to get today's date in YYYY-MM-DD
function getTodayDateString() {
  const d = new Date();
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// ----------------------------------------------------
// QR Code Management (Admin)
// ----------------------------------------------------

// POST /api/attendance/session - Admin generates new time-limited session
router.post('/session', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { validityMinutes = 2 } = req.body;
    const minutes = Math.max(1, parseInt(validityMinutes, 10) || 2);

    const now = new Date();
    const expiresAt = new Date(now.getTime() + minutes * 60 * 1000);

    const sessionId = `SESS_${Date.now()}`;
    const qrToken = `ATT_${crypto.randomBytes(8).toString('hex').toUpperCase()}`;

    // Mark previous active sessions as inactive
    db.prepare('UPDATE sessions SET is_active = 0 WHERE is_active = 1').run();

    const insert = db.prepare(`
      INSERT INTO sessions (session_id, qr_token, validity_minutes, created_by, created_at, expires_at, is_active)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `);

    insert.run(
      sessionId,
      qrToken,
      minutes,
      req.user.id,
      now.toISOString(),
      expiresAt.toISOString()
    );

    return res.status(201).json({
      success: true,
      message: 'Attendance QR session created successfully',
      data: {
        sessionId,
        qrToken,
        validityMinutes: minutes,
        createdAt: now.toISOString(),
        expiresAt: expiresAt.toISOString()
      }
    });
  } catch (error) {
    console.error('Create session error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create attendance session'
    });
  }
});

// GET /api/attendance/session/active - Get current active QR session
router.get('/session/active', authenticateToken, (req, res) => {
  try {
    const session = db.prepare(
      'SELECT * FROM sessions WHERE is_active = 1 ORDER BY id DESC LIMIT 1'
    ).get();

    if (!session) {
      return res.json({
        success: true,
        data: null,
        message: 'No active session found'
      });
    }

    const now = new Date();
    const expiresAt = new Date(session.expires_at);
    const isExpired = now.getTime() > expiresAt.getTime();

    return res.json({
      success: true,
      data: {
        sessionId: session.session_id,
        qrToken: session.qr_token,
        validityMinutes: session.validity_minutes,
        createdAt: session.created_at,
        expiresAt: session.expires_at,
        isExpired,
        remainingSeconds: Math.max(0, Math.floor((expiresAt.getTime() - now.getTime()) / 1000))
      }
    });
  } catch (error) {
    console.error('Get active session error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve active session'
    });
  }
});

// GET /api/attendance/session/:id - Get session details
router.get('/session/:id', authenticateToken, (req, res) => {
  try {
    const session = db.prepare('SELECT * FROM sessions WHERE session_id = ?').get(req.params.id);
    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }

    return res.json({
      success: true,
      data: {
        sessionId: session.session_id,
        qrToken: session.qr_token,
        validityMinutes: session.validity_minutes,
        createdAt: session.created_at,
        expiresAt: session.expires_at,
        isActive: session.is_active === 1
      }
    });
  } catch (error) {
    console.error('Get session by id error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve session'
    });
  }
});

// ----------------------------------------------------
// Employee Attendance Operations
// ----------------------------------------------------

// POST /api/attendance/check-in - Employee marks check-in
router.post('/check-in', authenticateToken, (req, res) => {
  try {
    const { qrToken, latitude, longitude } = req.body;
    const userId = req.user.id;

    if (!qrToken) {
      return res.status(400).json({
        success: false,
        message: 'QR code token is required'
      });
    }

    // 1. Validate QR Token existence
    const session = db.prepare('SELECT * FROM sessions WHERE qr_token = ?').get(qrToken.trim());
    if (!session) {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR code'
      });
    }

    // 2. Validate QR Expiry
    const now = new Date();
    const expiresAt = new Date(session.expires_at);
    if (now.getTime() > expiresAt.getTime()) {
      return res.status(400).json({
        success: false,
        message: 'QR code expired. Please ask administrator to generate a new QR code.'
      });
    }

    // 3. Prevent duplicate check-in today
    const today = getTodayDateString();
    const existing = db.prepare(
      'SELECT * FROM attendance WHERE user_id = ? AND date = ?'
    ).get(userId, today);

    if (existing && existing.check_in) {
      return res.status(409).json({
        success: false,
        message: 'Duplicate attendance: You have already checked in today',
        data: {
          attendanceId: existing.id,
          checkIn: existing.check_in,
          status: existing.status
        }
      });
    }

    // 4. Calculate status (e.g. if after 09:30 AM local time -> late, else present)
    const hours = now.getHours();
    const minutes = now.getMinutes();
    const isLate = hours > 9 || (hours === 9 && minutes > 30);
    const status = isLate ? 'late' : 'present';

    const checkInTime = now.toISOString();

    let attendanceId;
    if (existing) {
      // Update existing record if needed
      db.prepare(`
        UPDATE attendance 
        SET check_in = ?, session_id = ?, latitude_in = ?, longitude_in = ?, status = ?, updated_at = ?
        WHERE id = ?
      `).run(checkInTime, session.session_id, latitude || null, longitude || null, status, checkInTime, existing.id);
      attendanceId = existing.id;
    } else {
      const insert = db.prepare(`
        INSERT INTO attendance (user_id, session_id, date, check_in, latitude_in, longitude_in, status, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `);
      const result = insert.run(
        userId,
        session.session_id,
        today,
        checkInTime,
        latitude || null,
        longitude || null,
        status,
        checkInTime,
        checkInTime
      );
      attendanceId = result.lastInsertRowid;
    }

    return res.status(200).json({
      success: true,
      message: 'Check-in successful',
      data: {
        attendanceId,
        userId,
        name: req.user.name,
        checkIn: checkInTime,
        status,
        latitude: latitude || null,
        longitude: longitude || null
      }
    });
  } catch (error) {
    console.error('Check-in error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during check-in'
    });
  }
});

// POST /api/attendance/check-out - Employee marks check-out
router.post('/check-out', authenticateToken, (req, res) => {
  try {
    const { qrToken, latitude, longitude } = req.body;
    const userId = req.user.id;

    if (!qrToken) {
      return res.status(400).json({
        success: false,
        message: 'QR code token is required'
      });
    }

    // 1. Validate QR Token
    const session = db.prepare('SELECT * FROM sessions WHERE qr_token = ?').get(qrToken.trim());
    if (!session) {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR code'
      });
    }

    // 2. Validate QR Expiry
    const now = new Date();
    const expiresAt = new Date(session.expires_at);
    if (now.getTime() > expiresAt.getTime()) {
      return res.status(400).json({
        success: false,
        message: 'QR code expired. Please ask administrator to generate a new QR code.'
      });
    }

    // 3. Validate today's record and check-in existence
    const today = getTodayDateString();
    const existing = db.prepare(
      'SELECT * FROM attendance WHERE user_id = ? AND date = ?'
    ).get(userId, today);

    if (!existing || !existing.check_in) {
      return res.status(400).json({
        success: false,
        message: 'Check-in required before checking out'
      });
    }

    // 4. Validate already checked out
    if (existing.check_out) {
      return res.status(409).json({
        success: false,
        message: 'Already checked out for today',
        data: {
          attendanceId: existing.id,
          checkIn: existing.check_in,
          checkOut: existing.check_out,
          status: existing.status
        }
      });
    }

    const checkOutTime = now.toISOString();

    db.prepare(`
      UPDATE attendance 
      SET check_out = ?, latitude_out = ?, longitude_out = ?, updated_at = ?
      WHERE id = ?
    `).run(checkOutTime, latitude || null, longitude || null, checkOutTime, existing.id);

    return res.status(200).json({
      success: true,
      message: 'Check-out successful',
      data: {
        attendanceId: existing.id,
        userId,
        name: req.user.name,
        checkIn: existing.check_in,
        checkOut: checkOutTime,
        status: existing.status,
        latitude: latitude || null,
        longitude: longitude || null
      }
    });
  } catch (error) {
    console.error('Check-out error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during check-out'
    });
  }
});

// GET /api/attendance/today - Get logged in employee's today record
router.get('/today', authenticateToken, (req, res) => {
  try {
    const today = getTodayDateString();
    const record = db.prepare(
      'SELECT * FROM attendance WHERE user_id = ? AND date = ?'
    ).get(req.user.id, today);

    return res.json({
      success: true,
      data: record || null
    });
  } catch (error) {
    console.error('Get today attendance error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve today\'s attendance'
    });
  }
});

// GET /api/attendance/history - Get logged in employee's attendance history
router.get('/history', authenticateToken, (req, res) => {
  try {
    const records = db.prepare(
      'SELECT * FROM attendance WHERE user_id = ? ORDER BY date DESC, id DESC LIMIT 50'
    ).all(req.user.id);

    return res.json({
      success: true,
      data: records
    });
  } catch (error) {
    console.error('Get history error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve attendance history'
    });
  }
});

module.exports = router;

