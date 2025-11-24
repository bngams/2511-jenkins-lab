#!/bin/bash

# Script d'arrêt du Lab Jenkins
# Utilisation: ./stop.sh

echo "🛑 Arrêt du Lab Jenkins DevOps..."
echo ""

# Vérifier si des conteneurs sont en cours d'exécution
if [ -z "$(docker-compose ps -q)" ]; then
    echo "ℹ️  Aucun service en cours d'exécution"
    exit 0
fi

echo "📊 Services actuellement en cours d'exécution:"
docker-compose ps
echo ""

read -p "Voulez-vous arrêter tous les services? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Arrêt des services..."
    docker-compose down
    
    echo ""
    echo "✅ Tous les services ont été arrêtés"
    echo ""
    echo "💡 Les données sont conservées dans les volumes Docker"
    echo "   Pour supprimer aussi les volumes: ./reset.sh"
else
    echo "❌ Arrêt annulé"
fi
