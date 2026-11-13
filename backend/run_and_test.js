const { spawn } = require('child_process');
const path = require('path');

const serverProcess = spawn('node', ['server.js'], {
  cwd: path.join(__dirname),
  stdio: 'inherit'
});

setTimeout(() => {
  const testProcess = spawn('node', ['test_api.js'], {
    cwd: path.join(__dirname),
    stdio: 'inherit'
  });

  testProcess.on('exit', (code) => {
    console.log(`\nTests finished with exit code ${code}. Stopping server...`);
    serverProcess.kill('SIGINT');
    process.exit(code);
  });
}, 1500);

