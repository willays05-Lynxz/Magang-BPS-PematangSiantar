const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <!DOCTYPE html>
      <html lang="id">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistem Geotagging Usaha - BPS Pematang Siantar</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
          }
          .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          h1 {
            color: #2c3e50;
            text-align: center;
          }
          .info {
            background: #e3f2fd;
            padding: 15px;
            border-left: 4px solid #2196f3;
            margin: 20px 0;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🗺️ Sistem Geotagging Usaha</h1>
          <h2>BPS Pematang Siantar</h2>
          
          <div class="info">
            <p><strong>Status:</strong> Server berhasil berjalan!</p>
            <p><strong>Port:</strong> 3000</p>
            <p><strong>Waktu:</strong> ${new Date().toLocaleString('id-ID')}</p>
          </div>
          
          <p>Selamat datang di Sistem Geotagging Usaha untuk wilayah Pematang Siantar.</p>
          <p>Sistem ini digunakan untuk melakukan pemetaan dan pendataan usaha dengan koordinat geografis.</p>
          
          <h3>Fitur yang akan dikembangkan:</h3>
          <ul>
            <li>📍 Input koordinat geografis</li>
            <li>🏪 Pendataan informasi usaha</li>
            <li>🗺️ Visualisasi peta interaktif</li>
            <li>📊 Laporan dan analisis data</li>
          </ul>
        </div>
      </body>
      </html>
    `);
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Page not found');
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('Sistem Geotagging Usaha - BPS Pematang Siantar');
});
