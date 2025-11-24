const request = require('supertest');
const app = require('./app');

describe('Sample Node.js App - API Tests', () => {
  
  // Test de la route principale
  describe('GET /', () => {
    it('should return welcome message with 200 status', async () => {
      const response = await request(app).get('/');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('Welcome');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  // Test du health check
  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('timestamp');
    });

    it('should have positive uptime', async () => {
      const response = await request(app).get('/health');
      
      expect(response.body.uptime).toBeGreaterThan(0);
    });
  });

  // Test de la version
  describe('GET /version', () => {
    it('should return version information', async () => {
      const response = await request(app).get('/version');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('node');
      expect(response.body).toHaveProperty('platform');
      expect(response.body).toHaveProperty('arch');
    });

    it('should return valid version format', async () => {
      const response = await request(app).get('/version');
      
      expect(response.body.version).toMatch(/^\d+\.\d+\.\d+$/);
    });
  });

  // Test de l'endpoint API info
  describe('GET /api/info', () => {
    it('should return API information', async () => {
      const response = await request(app).get('/api/info');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('description');
      expect(response.body).toHaveProperty('endpoints');
      expect(Array.isArray(response.body.endpoints)).toBe(true);
    });

    it('should list all available endpoints', async () => {
      const response = await request(app).get('/api/info');
      
      const endpointPaths = response.body.endpoints.map(e => e.path);
      expect(endpointPaths).toContain('/');
      expect(endpointPaths).toContain('/health');
      expect(endpointPaths).toContain('/version');
    });
  });

  // Test du deployment test endpoint
  describe('GET /deployment/test', () => {
    it('should confirm successful deployment', async () => {
      const response = await request(app).get('/deployment/test');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message', 'Deployment successful!');
      expect(response.body).toHaveProperty('deployedAt');
    });
  });

  // Test des routes 404
  describe('GET /nonexistent', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app).get('/nonexistent');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Not Found');
    });
  });

  // Test de la structure JSON
  describe('Response Headers', () => {
    it('should return JSON content-type', async () => {
      const response = await request(app).get('/');
      
      expect(response.headers['content-type']).toMatch(/json/);
    });
  });
});
