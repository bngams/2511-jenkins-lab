# Sample Node.js Application

This is a sample Node.js application for testing Jenkins CI/CD pipeline.

## Features

- Simple HTTP server
- Basic health check endpoint
- Unit tests
- Docker support

## Local Development

```bash
# Install dependencies
npm install

# Run the application
npm start

# Run tests
npm test

# Run with Docker
docker build -t sample-nodejs-app .
docker run -p 3000:3000 sample-nodejs-app
```

## API Endpoints

- `GET /` - Returns welcome message
- `GET /health` - Health check endpoint
- `GET /version` - Returns application version

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development, production)

## CI/CD

This project includes a Jenkinsfile for automated CI/CD pipeline.

The pipeline includes:
1. Checkout code from GitLab
2. Install dependencies
3. Run tests
4. Build Docker image
5. Push to registry (optional)
6. Deploy to staging (optional)
