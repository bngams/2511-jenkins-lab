module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'app.js',
    '!node_modules/**',
    '!coverage/**'
  ],
  coverageReporters: ['text', 'lcov', 'html'],
  testMatch: ['**/*.test.js'],
  verbose: true,
  testTimeout: 10000,
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50
    }
  }
};
