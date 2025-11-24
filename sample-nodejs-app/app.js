const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const VERSION = process.env.npm_package_version || '1.0.0';
const ENV = process.env.NODE_ENV || 'development';

// Middleware pour parser JSON
app.use(express.json());

// Middleware de logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Route principale
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Sample Node.js App!',
    description: 'This is a demo application for Jenkins CI/CD training',
    environment: ENV,
    version: VERSION,
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: ENV
  });
});

// Version endpoint
app.get('/version', (req, res) => {
  res.json({
    version: VERSION,
    node: process.version,
    platform: process.platform,
    arch: process.arch
  });
});

// API info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Sample Node.js App',
    description: 'CI/CD Training Application',
    version: VERSION,
    endpoints: [
      { path: '/', method: 'GET', description: 'Welcome message' },
      { path: '/health', method: 'GET', description: 'Health check' },
      { path: '/version', method: 'GET', description: 'Version info' },
      { path: '/api/info', method: 'GET', description: 'API information' }
    ]
  });
});

// Route de test pour les déploiements
app.get('/deployment/test', (req, res) => {
  res.json({
    message: 'Deployment successful!',
    deployedAt: new Date().toISOString(),
    environment: ENV,
    version: VERSION
  });
});

// Route 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    message: 'The requested resource was not found'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// Démarrer le serveur seulement si ce fichier est exécuté directement
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(50));
    console.log(`🚀 Server started successfully!`);
    console.log(`📍 Environment: ${ENV}`);
    console.log(`📍 Version: ${VERSION}`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`📍 URL: http://localhost:${PORT}`);
    console.log('='.repeat(50));
  });
}

// Exporter l'app pour les tests
module.exports = app;
