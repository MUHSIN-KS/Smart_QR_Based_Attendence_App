const { DatabaseSync } = require('node:sqlite');
const path = require('node:path');
const bcrypt = require('bcryptjs');

const dbPath = path.join(__dirname, 'attendance.db');
const db = new DatabaseSync(dbPath);

// Enable WAL mode for better concurrency and foreign keys
db.exec('PRAGMA foreign_keys = ON;');

// Initialize tables
function initDb() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'employee',
      department TEXT DEFAULT 'Operations',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT UNIQUE NOT NULL,
      qr_token TEXT UNIQUE NOT NULL,
      validity_minutes INTEGER NOT NULL,
      created_by INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      expires_at DATETIME NOT NULL,
      is_active INTEGER DEFAULT 1,
      FOREIGN KEY (created_by) REFERENCES users (id)
    );

    CREATE TABLE IF NOT EXISTS attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      session_id TEXT NOT NULL,
      date TEXT NOT NULL,
      check_in DATETIME,
      check_out DATETIME,
      latitude_in REAL,
      longitude_in REAL,
      latitude_out REAL,
      longitude_out REAL,
      status TEXT NOT NULL DEFAULT 'present',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    );
  `);

  // Seed default admin and employees if empty
  const countRow = db.prepare('SELECT COUNT(*) as count FROM users').get();
  if (countRow.count === 0) {
    console.log('Seeding initial users...');
    const salt = bcrypt.genSaltSync(10);
    const adminPassword = bcrypt.hashSync('admin123', salt);
    const empPassword = bcrypt.hashSync('123456', salt);

    const insertUser = db.prepare(
      'INSERT INTO users (name, email, password, role, department) VALUES (?, ?, ?, ?, ?)'
    );

    insertUser.run('Admin Manager', 'admin@company.com', adminPassword, 'admin', 'Management');
    insertUser.run('Justin Johnson', 'employee@test.com', empPassword, 'employee', 'Operations');
    insertUser.run('Sarah Connor', 'sarah@company.com', empPassword, 'employee', 'Drilling Tech');
    insertUser.run('Alex Martinez', 'alex@company.com', empPassword, 'employee', 'Field Engineering');

    console.log('Default users seeded:');
    console.log('  Admin: admin@company.com / admin123');
    console.log('  Employee: employee@test.com / 123456');
    console.log('  Employee: sarah@company.com / 123456');
    console.log('  Employee: alex@company.com / 123456');
  }
}

initDb();

module.exports = db;

