# Multi-stage build pour optimiser la taille de l'image

# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Stage 2: Production
FROM node:20-alpine

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copier les dépendances depuis le stage builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copier le code source
COPY --chown=nodejs:nodejs . .

# Définir l'utilisateur
USER nodejs

# Exposer le port
EXPOSE 3000

# Variables d'environnement
ENV NODE_ENV=production \
    PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Commande de démarrage
CMD ["node", "app.js"]
