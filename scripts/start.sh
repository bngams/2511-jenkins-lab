#!/bin/bash

# Script de démarrage du Lab Jenkins
# Utilisation: ./start.sh [gitlab|gitea]
# Par défaut: pas de serveur Git (services core uniquement)

set -e

# Parse argument pour le profil Git
GIT_PROFILE=""
if [ "$1" == "gitlab" ]; then
    GIT_PROFILE="--profile gitlab"
    GIT_SERVICE="GitLab"
elif [ "$1" == "gitea" ]; then
    GIT_PROFILE="--profile gitea"
    GIT_SERVICE="Gitea"
elif [ -n "$1" ]; then
    echo "❌ Erreur: Profil inconnu '$1'"
    echo "   Usage: ./start.sh [gitlab|gitea]"
    echo "   Sans argument: démarre uniquement les services core (Jenkins, SonarQube, Staging)"
    exit 1
fi

echo "🚀 Démarrage du Lab Jenkins DevOps..."
if [ -n "$GIT_SERVICE" ]; then
    echo "   Profil Git: $GIT_SERVICE"
fi
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
if [ "$1" == "gitlab" ]; then
    echo "⚠️  Minimum recommandé avec GitLab: 8GB"
else
    echo "⚠️  Minimum recommandé: 4GB (6GB avec GitLab)"
fi
echo ""

# Construire les images personnalisées
echo "🔨 Construction des images Docker personnalisées..."
docker-compose build --no-cache

echo ""
echo "📦 Démarrage des services..."
docker-compose $GIT_PROFILE up -d

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
if [ "$1" == "gitlab" ] || [ "$1" == "gitea" ]; then
    echo "   - $GIT_SERVICE:    http://localhost:8090"
fi
echo "   - SonarQube: http://localhost:9000"
echo "   - Staging:   http://localhost:8081"
echo ""
echo "🔑 Mot de passe initial Jenkins:"
echo "   Exécutez: docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
if [ "$1" == "gitlab" ]; then
    echo "🔑 Credentials GitLab par défaut:"
    echo "   Username: root"
    echo "   Password: rootpassword123"
    echo "   ⏱️  GitLab peut prendre 3-5 minutes pour être complètement opérationnel"
    echo ""
elif [ "$1" == "gitea" ]; then
    echo "🔑 Gitea - Premier démarrage:"
    echo "   Créez votre compte admin sur http://localhost:8090"
    echo "   ⏱️  Gitea est généralement prêt en 30 secondes"
    echo ""
fi
echo "📖 Consultez le guide: PARTIE-1-GUIDE.md"
echo ""
echo "💡 Astuce: Utilisez './start.sh gitlab' ou './start.sh gitea' pour choisir votre serveur Git"
echo "👀 Pour voir les logs: docker-compose logs -f <service>"
echo "🛑 Pour arrêter: ./stop.sh ou docker-compose down"
