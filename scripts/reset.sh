#!/bin/bash

# Script de réinitialisation complète du Lab Jenkins
# ⚠️  ATTENTION: Ce script supprime TOUTES les données!
# Utilisation: ./reset.sh

set -e

echo "⚠️  RÉINITIALISATION COMPLÈTE DU LAB ⚠️"
echo ""
echo "Ce script va:"
echo "  - Arrêter tous les services"
echo "  - Supprimer tous les volumes Docker (DONNÉES PERDUES)"
echo "  - Nettoyer les images Docker créées"
echo ""
echo "❌ Cette action est IRRÉVERSIBLE!"
echo ""

read -p "Êtes-vous sûr de vouloir continuer? (tapez 'yes' pour confirmer): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "❌ Réinitialisation annulée"
    exit 0
fi

echo ""
echo "🔄 Arrêt et suppression des services..."
docker-compose down -v

echo ""
echo "🧹 Nettoyage des images Docker..."
docker-compose down --rmi local

echo ""
echo "🗑️  Nettoyage des images orphelines..."
docker image prune -f

echo ""
echo "✅ Réinitialisation complète effectuée"
echo ""
echo "🔄 Pour redémarrer le lab:"
echo "   ./start.sh"
