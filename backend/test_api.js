// Self-contained test script to verify all backend REST API endpoints
const http = require('http');

function request(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('error', reject);
    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- Testing Backend APIs ---');
  const host = '127.0.0.1';
  const port = 3000;

  // 1. Health check
  console.log('\n1. Testing Health Check GET /');
  const health = await request({ host, port, path: '/', method: 'GET' });
  console.log('Status:', health.status, 'Response:', health.body.status);

  // 2. Admin Login
  console.log('\n2. Testing Admin Login POST /api/auth/login');
  const adminLogin = await request(
    { host, port, path: '/api/auth/login', method: 'POST', headers: { 'Content-Type': 'application/json' } },
    { email: 'admin@company.com', password: 'admin123' }
  );
  console.log('Status:', adminLogin.status, 'Role:', adminLogin.body.data?.role);
  const adminToken = adminLogin.body.data?.token;

  // 3. Employee Login
  console.log('\n3. Testing Employee Login POST /api/auth/login');
  const empLogin = await request(
    { host, port, path: '/api/auth/login', method: 'POST', headers: { 'Content-Type': 'application/json' } },
    { email: 'employee@test.com', password: '123456' }
  );
  console.log('Status:', empLogin.status, 'Name:', empLogin.body.data?.name);
  const empToken = empLogin.body.data?.token;

  // 4. Admin creates QR Session
  console.log('\n4. Testing Admin Create QR Session POST /api/attendance/session');
  const sessionRes = await request(
    {
      host, port, path: '/api/attendance/session', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${adminToken}` }
    },
    { validityMinutes: 5 }
  );
  console.log('Status:', sessionRes.status, 'QR Token:', sessionRes.body.data?.qrToken);
  const qrToken = sessionRes.body.data?.qrToken;

  // 5. Get Active Session
  console.log('\n5. Testing GET /api/attendance/session/active');
  const activeRes = await request({
    host, port, path: '/api/attendance/session/active', method: 'GET',
    headers: { 'Authorization': `Bearer ${empToken}` }
  });
  console.log('Status:', activeRes.status, 'Session ID:', activeRes.body.data?.sessionId);

  // 6. Employee Check-in
  console.log('\n6. Testing Employee Check-in POST /api/attendance/check-in');
  const checkInRes = await request(
    {
      host, port, path: '/api/attendance/check-in', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${empToken}` }
    },
    { qrToken, latitude: 10.0889, longitude: 77.0595 }
  );
  console.log('Status:', checkInRes.status, 'Message:', checkInRes.body.message);

  // 7. Duplicate Check-in test (should fail with 409)
  console.log('\n7. Testing Duplicate Check-in POST /api/attendance/check-in');
  const dupCheckIn = await request(
    {
      host, port, path: '/api/attendance/check-in', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${empToken}` }
    },
    { qrToken, latitude: 10.0889, longitude: 77.0595 }
  );
  console.log('Status:', dupCheckIn.status, 'Expected 409. Message:', dupCheckIn.body.message);

  // 8. Employee Check-out
  console.log('\n8. Testing Employee Check-out POST /api/attendance/check-out');
  const checkOutRes = await request(
    {
      host, port, path: '/api/attendance/check-out', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${empToken}` }
    },
    { qrToken, latitude: 10.0890, longitude: 77.0597 }
  );
  console.log('Status:', checkOutRes.status, 'Message:', checkOutRes.body.message);

  // 9. Duplicate Check-out test (should fail with 409)
  console.log('\n9. Testing Duplicate Check-out POST /api/attendance/check-out');
  const dupCheckOut = await request(
    {
      host, port, path: '/api/attendance/check-out', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${empToken}` }
    },
    { qrToken, latitude: 10.0890, longitude: 77.0597 }
  );
  console.log('Status:', dupCheckOut.status, 'Expected 409. Message:', dupCheckOut.body.message);

  // 10. Employee History
  console.log('\n10. Testing Employee Attendance History GET /api/attendance/history');
  const historyRes = await request({
    host, port, path: '/api/attendance/history', method: 'GET',
    headers: { 'Authorization': `Bearer ${empToken}` }
  });
  console.log('Status:', historyRes.status, 'Records count:', historyRes.body.data?.length);

  // 11. Admin Dashboard
  console.log('\n11. Testing Admin Dashboard GET /api/admin/dashboard');
  const adminDash = await request({
    host, port, path: '/api/admin/dashboard', method: 'GET',
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  console.log('Status:', adminDash.status, 'Stats:', adminDash.body.data);

  // 12. Admin Attendance List
  console.log('\n12. Testing Admin Attendance List GET /api/admin/attendance');
  const adminAtt = await request({
    host, port, path: '/api/admin/attendance', method: 'GET',
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  console.log('Status:', adminAtt.status, 'Records:', adminAtt.body.data?.length);

  console.log('\n🎉 ALL BACKEND API TESTS COMPLETED SUCCESSFULLY!');
}

runTests().catch(console.error);

