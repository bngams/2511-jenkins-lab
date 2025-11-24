# 📚 Guide de Référence Rapide - Jenkins Lab

## 🚀 Démarrage et Arrêt

```bash
# Démarrer le lab
./scripts/start.sh

# Arrêter le lab
./scripts/stop.sh

# Réinitialiser complètement
./scripts/reset.sh

# Diagnostic
./scripts/diagnose.sh
```

## 🐳 Commandes Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Voir les services en cours
docker-compose ps

# Voir les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f jenkins-master
docker-compose logs -f gitlab
docker-compose logs -f sonarqube

# Redémarrer un service
docker-compose restart jenkins-master

# Reconstruire les images
docker-compose build

# Arrêter et supprimer les volumes
docker-compose down -v
```

## 🔧 Commandes Jenkins

```bash
# Récupérer le mot de passe initial
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

# Accéder au conteneur Jenkins
docker exec -it jenkins-master bash

# Voir les logs Jenkins
docker logs -f jenkins-master

# Redémarrer Jenkins
docker restart jenkins-master

# Sauvegarder la configuration Jenkins
docker cp jenkins-master:/var/jenkins_home ./jenkins-backup
```

## 🦊 Commandes GitLab

```bash
# Vérifier le statut de GitLab
docker exec gitlab gitlab-ctl status

# Voir les logs GitLab
docker logs -f gitlab

# Accéder au conteneur GitLab
docker exec -it gitlab bash

# Redémarrer GitLab
docker restart gitlab

# Vérifier la santé de GitLab
docker exec gitlab gitlab-rake gitlab:check

# Réinitialiser le mot de passe root
docker exec -it gitlab gitlab-rake "gitlab:password:reset[root]"
```

## 📊 Commandes SonarQube

```bash
# Voir les logs SonarQube
docker logs -f sonarqube

# Accéder au conteneur SonarQube
docker exec -it sonarqube bash

# Redémarrer SonarQube
docker restart sonarqube
```

## 🎯 Commandes Staging Server

```bash
# Accéder au serveur staging
docker exec -it staging-server bash

# Voir les logs nginx
docker exec staging-server tail -f /var/log/nginx_access.log

# Redémarrer nginx
docker exec staging-server supervisorctl restart nginx

# Lister les conteneurs déployés
docker exec staging-server docker ps
```

## 🔍 Diagnostic et Troubleshooting

```bash
# Vérifier l'état de tous les conteneurs
docker ps -a

# Vérifier l'utilisation des ressources
docker stats

# Vérifier les réseaux
docker network ls
docker network inspect jenkins-lab_jenkins-network

# Vérifier les volumes
docker volume ls
docker volume inspect jenkins-lab_jenkins-master-data

# Tester la connectivité réseau
docker exec jenkins-master ping -c 2 gitlab
docker exec jenkins-master ping -c 2 sonarqube
docker exec jenkins-master ping -c 2 staging-server

# Vérifier Docker dans le slave
docker exec jenkins-slave docker ps
docker exec jenkins-slave docker images

# Voir tous les processus dans un conteneur
docker top jenkins-master
```

## 🧹 Nettoyage

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune -a

# Supprimer les volumes non utilisés
docker volume prune

# Nettoyage complet du système
docker system prune -a --volumes

# Supprimer uniquement les ressources du lab
docker-compose down -v --rmi all
```

## 📦 Gestion des Builds Jenkins

```bash
# Déclencher un build via CLI (nécessite jenkins-cli.jar)
java -jar jenkins-cli.jar -s http://localhost:8080/ build <job-name>

# Vérifier le statut d'un build
curl http://localhost:8080/job/<job-name>/lastBuild/api/json

# Récupérer les logs d'un build
curl http://localhost:8080/job/<job-name>/lastBuild/consoleText
```

## 🔗 URLs Utiles

| Service | URL | Credentials |
|---------|-----|-------------|
| Jenkins | http://localhost:8080 | admin / voir password initial |
| GitLab | http://localhost:8090 | root / rootpassword123 |
| SonarQube | http://localhost:9000 | admin / admin |
| Staging | http://localhost:8081 | N/A |
| App déployée | http://localhost:8082 | N/A |

## 🐛 Problèmes Courants et Solutions

### Jenkins ne démarre pas
```bash
# Vérifier les logs
docker logs jenkins-master

# Vérifier les permissions du socket Docker
ls -l /var/run/docker.sock

# Augmenter la mémoire allouée à Docker
```

### GitLab trop lent
```bash
# GitLab nécessite minimum 4GB RAM
# Vérifier la mémoire disponible
docker stats gitlab

# Désactiver des fonctionnalités dans gitlab.rb si nécessaire
```

### Le webhook ne fonctionne pas
```bash
# Vérifier la connectivité
docker exec gitlab ping -c 2 jenkins-master

# Vérifier l'URL du webhook (doit utiliser jenkins-master, pas localhost)
# Vérifier le secret token

# Tester manuellement le webhook depuis GitLab UI
```

### Docker dans Jenkins ne fonctionne pas
```bash
# Vérifier que le socket est monté
docker exec jenkins-slave ls -l /var/run/docker.sock

# Vérifier les permissions
docker exec jenkins-slave id

# Redémarrer le slave
docker restart jenkins-slave
```

### Port déjà utilisé
```bash
# Identifier le processus utilisant le port
lsof -i :8080
# ou
netstat -an | grep 8080

# Changer le port dans docker-compose.yml
# Ou arrêter le service utilisant le port
```

## 💡 Astuces et Bonnes Pratiques

### Sauvegarder avant des modifications importantes
```bash
# Sauvegarder les volumes Docker
docker run --rm -v jenkins-lab_jenkins-master-data:/data -v $(pwd):/backup alpine tar czf /backup/jenkins-backup.tar.gz /data
```

### Surveiller les ressources
```bash
# Monitoring en temps réel
watch -n 2 'docker stats --no-stream'
```

### Logs centralisés
```bash
# Voir tous les logs en même temps
docker-compose logs -f | grep -i error
```

### Tester rapidement un endpoint
```bash
# Test rapide de l'application
curl -s http://localhost:8082/health | jq
```

## 📚 Commandes Git Utiles (dans GitLab)

```bash
# Cloner un repo depuis GitLab local
git clone http://localhost:8090/root/sample-nodejs-app.git

# Ajouter l'authentification
git config --global credential.helper store

# Push vers GitLab
git add .
git commit -m "Update pipeline"
git push origin main
```

## 🔐 Gestion des Credentials

### Jenkins
```bash
# Liste des credentials (via groovy console)
# Manage Jenkins > Script Console
```

### GitLab Token
```bash
# Créer un token:
# User Settings > Access Tokens
# Scopes: api, read_repository, write_repository
```

## 📊 Monitoring et Métriques

```bash
# Utilisation mémoire de chaque service
docker stats --no-stream

# Espace disque utilisé
docker system df

# Logs en temps réel avec filtre
docker-compose logs -f | grep -E "(ERROR|WARN|SUCCESS)"
```

---

**💡 Conseil**: Ajoutez cette page à vos favoris pour un accès rapide pendant le lab!

**🆘 Besoin d'aide?** Consultez le guide complet: `PARTIE-1-GUIDE.md`
