#!/bin/bash

# Script de démarrage du Lab Jenkins
# Utilisation: ./start.sh

set -e

echo "🚀 Démarrage du Lab Jenkins DevOps..."
echo ""

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "❌ Erreur: Docker n'est pas en cours d'exécution."
    echo "   Veuillez démarrer Docker Desktop ou le daemon Docker."
    exit 1
fi

echo "✅ Docker est opérationnel"
echo ""

# Vérifier les ressources disponibles
TOTAL_RAM=$(docker info --format '{{.MemTotal}}' 2>/dev/null | numfmt --to=iec --from-unit=1 || echo "Unknown")
echo "💾 Mémoire disponible pour Docker: $TOTAL_RAM"
echo "⚠️  Minimum recommandé: 8GB"
echo ""

# Construire les images personnalisées
echo "🔨 Construction des images Docker personnalisées..."
docker-compose build --no-cache

echo ""
echo "📦 Démarrage des services..."
docker-compose up -d

echo ""
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier l'état des services
echo ""
echo "📊 État des services:"
docker-compose ps

echo ""
echo "🎉 Lab démarré avec succès!"
echo ""
echo "📌 Accès aux services:"
echo "   - Jenkins:   http://localhost:8080"
echo "   - GitLab:    http://localhost:8090"
echo "   - SonarQube: http://localhost:9000"
echo "   - Staging:   http://localhost:8081"
echo ""
echo "🔑 Mot de passe initial Jenkins:"
echo "   Exécutez: docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "🔑 Credentials GitLab par défaut:"
echo "   Username: root"
echo "   Password: rootpassword123"
echo ""
echo "📖 Consultez le guide: PARTIE-1-GUIDE.md"
echo ""
echo "⏱️  GitLab peut prendre 3-5 minutes pour être complètement opérationnel"
echo ""
echo "👀 Pour voir les logs: docker-compose logs -f <service>"
echo "🛑 Pour arrêter: ./stop.sh ou docker-compose down"
