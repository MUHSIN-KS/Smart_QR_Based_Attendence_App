const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('../database');
const { generateToken, authenticateToken } = require('../middleware/auth');

// POST /api/auth/login
router.post('/login', (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    const user = db.prepare('SELECT * FROM users WHERE LOWER(email) = LOWER(?)').get(email.trim());

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const isMatch = bcrypt.compareSync(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const token = generateToken(user);

    return res.json({
      success: true,
      message: 'Login successful',
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        department: user.department,
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during login'
    });
  }
});

// POST /api/auth/register
router.post('/register', (req, res) => {
  try {
    const { name, email, password, role = 'employee', department = 'General' } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, and password are required'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters'
      });
    }

    const existing = db.prepare('SELECT id FROM users WHERE LOWER(email) = LOWER(?)').get(email.trim());
    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'An account with this email already exists'
      });
    }

    const salt = bcrypt.genSaltSync(10);
    const hashedPassword = bcrypt.hashSync(password, salt);
    const validRole = role === 'admin' ? 'admin' : 'employee';

    const insert = db.prepare(
      'INSERT INTO users (name, email, password, role, department) VALUES (?, ?, ?, ?, ?)'
    );
    const result = insert.run(name.trim(), email.trim().toLowerCase(), hashedPassword, validRole, department.trim());

    const newUser = db.prepare('SELECT id, name, email, role, department, created_at FROM users WHERE id = ?').get(result.lastInsertRowid);
    const token = generateToken(newUser);

    return res.status(201).json({
      success: true,
      message: 'Account registered successfully',
      data: {
        ...newUser,
        token
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during registration'
    });
  }
});

// GET /api/auth/profile
router.get('/profile', authenticateToken, (req, res) => {
  try {
    const user = db.prepare('SELECT id, name, email, role, department, created_at FROM users WHERE id = ?').get(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User profile not found'
      });
    }

    return res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;

