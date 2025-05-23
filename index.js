const http = require('http');
const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/healthz') {
    console.log('Health check accessed');
    res.writeHead(200);
    return res.end('OK');
  }

  console.log(`Received request for ${req.url}`);
  res.writeHead(200);
  res.end('Dynatrace Node.js test app is running!');
});

server.listen(port, () => {
  console.log(`App listening on port ${port}`);
});

// Simulate traffic every 30 seconds
setInterval(() => {
  http.get(`http://localhost:${port}/healthz`, (res) => {
    console.log(`Self-check: ${res.statusCode}`);
  }).on('error', (err) => {
    console.error('Self-check failed:', err.message);
  });
}, 30000);
