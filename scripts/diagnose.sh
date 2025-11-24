#!/bin/bash

# Script de diagnostic du Lab Jenkins
# Utilisation: ./diagnose.sh

echo "🔍 DIAGNOSTIC DU LAB JENKINS"
echo "=============================="
echo ""

# 1. Vérifier Docker
echo "1️⃣  Vérification de Docker"
echo "----------------------------"
if docker info > /dev/null 2>&1; then
    echo "✅ Docker est opérationnel"
    DOCKER_VERSION=$(docker --version)
    echo "   Version: $DOCKER_VERSION"
    TOTAL_RAM=$(docker info --format '{{.MemTotal}}' 2>/dev/null | numfmt --to=iec --from-unit=1 || echo "Unknown")
    echo "   RAM disponible: $TOTAL_RAM"
else
    echo "❌ Docker n'est pas en cours d'exécution"
    echo "   Action: Démarrez Docker Desktop ou le daemon Docker"
    exit 1
fi
echo ""

# 2. Vérifier Docker Compose
echo "2️⃣  Vérification de Docker Compose"
echo "----------------------------"
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo "✅ Docker Compose installé"
    echo "   Version: $COMPOSE_VERSION"
else
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi
echo ""

# 3. État des conteneurs
echo "3️⃣  État des conteneurs"
echo "----------------------------"
if [ -z "$(docker-compose ps -q)" ]; then
    echo "⚠️  Aucun conteneur en cours d'exécution"
    echo "   Action: Exécutez ./start.sh pour démarrer le lab"
else
    docker-compose ps
    
    # Vérifier les conteneurs individuellement
    echo ""
    echo "Détails des services:"
    
    services=("jenkins-master" "jenkins-slave" "gitlab" "sonarqube" "staging-server")
    for service in "${services[@]}"; do
        if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
            status=$(docker inspect --format='{{.State.Status}}' $service)
            health=$(docker inspect --format='{{.State.Health.Status}}' $service 2>/dev/null || echo "no healthcheck")
            echo "  ✅ $service: $status ($health)"
        else
            echo "  ❌ $service: non démarré"
        fi
    done
fi
echo ""

# 4. Connectivité réseau
echo "4️⃣  Connectivité réseau"
echo "----------------------------"
if docker ps --format '{{.Names}}' | grep -q "jenkins-master"; then
    echo "Test de connectivité depuis jenkins-master:"
    
    targets=("gitlab" "sonarqube" "staging-server" "jenkins-slave")
    for target in "${targets[@]}"; do
        if docker exec jenkins-master ping -c 1 -W 2 $target > /dev/null 2>&1; then
            echo "  ✅ jenkins-master → $target"
        else
            echo "  ❌ jenkins-master ✗ $target"
        fi
    done
else
    echo "⚠️  jenkins-master n'est pas démarré"
fi
echo ""

# 5. Ports
echo "5️⃣  Vérification des ports"
echo "----------------------------"
ports=(8080 8090 9000 8081)
port_names=("Jenkins" "GitLab" "SonarQube" "Staging")

for i in "${!ports[@]}"; do
    port=${ports[$i]}
    name=${port_names[$i]}
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -an 2>/dev/null | grep -q ":$port.*LISTEN" || ss -tuln 2>/dev/null | grep -q ":$port"; then
        echo "  ✅ Port $port ($name) est utilisé"
    else
        echo "  ❌ Port $port ($name) n'est pas utilisé"
    fi
done
echo ""

# 6. Volumes Docker
echo "6️⃣  Volumes Docker"
echo "----------------------------"
volumes=$(docker volume ls --format '{{.Name}}' | grep jenkins-lab || echo "")
if [ -z "$volumes" ]; then
    echo "⚠️  Aucun volume trouvé"
else
    echo "Volumes créés:"
    echo "$volumes" | while read vol; do
        size=$(docker system df -v 2>/dev/null | grep "$vol" | awk '{print $3}' || echo "Unknown")
        echo "  📦 $vol ($size)"
    done
fi
echo ""

# 7. Logs récents
echo "7️⃣  Logs récents (erreurs uniquement)"
echo "----------------------------"
if [ ! -z "$(docker-compose ps -q)" ]; then
    echo "Recherche d'erreurs dans les logs des dernières 5 minutes..."
    docker-compose logs --since 5m 2>&1 | grep -i error | head -10 || echo "  ✅ Aucune erreur trouvée"
else
    echo "⚠️  Aucun service en cours d'exécution"
fi
echo ""

# 8. URLs d'accès
echo "8️⃣  URLs d'accès"
echo "----------------------------"
echo "  🔧 Jenkins:   http://localhost:8080"
echo "  🦊 GitLab:    http://localhost:8090"
echo "  📊 SonarQube: http://localhost:9000"
echo "  🎯 Staging:   http://localhost:8081"
echo ""

# 9. Credentials
echo "9️⃣  Credentials par défaut"
echo "----------------------------"
if docker ps --format '{{.Names}}' | grep -q "jenkins-master"; then
    echo "  Jenkins initial password:"
    jenkins_password=$(docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Non disponible")
    echo "    $jenkins_password"
else
    echo "  Jenkins: non démarré"
fi
echo ""
echo "  GitLab:"
echo "    Username: root"
echo "    Password: rootpassword123"
echo ""
echo "  SonarQube:"
echo "    Username: admin"
echo "    Password: admin"
echo ""

# 10. Résumé et recommandations
echo "🎯 RÉSUMÉ"
echo "----------------------------"

running_count=$(docker-compose ps | grep -c "Up" || echo 0)
total_services=5

if [ "$running_count" -eq "$total_services" ]; then
    echo "✅ Tous les services sont opérationnels ($running_count/$total_services)"
    echo ""
    echo "💡 Prochaines étapes:"
    echo "   1. Accédez à Jenkins: http://localhost:8080"
    echo "   2. Suivez le guide: PARTIE-1-GUIDE.md"
elif [ "$running_count" -eq 0 ]; then
    echo "⚠️  Aucun service n'est démarré"
    echo ""
    echo "💡 Action recommandée:"
    echo "   ./start.sh"
else
    echo "⚠️  Certains services ne sont pas démarrés ($running_count/$total_services)"
    echo ""
    echo "💡 Actions recommandées:"
    echo "   1. Vérifiez les logs: docker-compose logs <service>"
    echo "   2. Redémarrez le lab: ./reset.sh puis ./start.sh"
fi

echo ""
echo "📚 Pour plus d'aide, consultez README.md section Troubleshooting"
