# 🚀 Lab Jenkins Avancé - Formation DevOps

Ce repository contient un laboratoire complet pour apprendre à mettre en place une infrastructure CI/CD moderne avec Jenkins, GitLab, SonarQube et Docker.

## 📋 Vue d'ensemble

Ce lab est divisé en plusieurs parties progressives qui vous permettront de maîtriser :

### ✅ PARTIE 1 : Infrastructure et bases
- Installation complète via Docker Compose
- Configuration Jenkins Master/Slave avec Docker
- Intégration GitLab avec webhooks
- Utilisation du plugin Docker Pipeline
- Premier déploiement automatisé

### 🔜 PARTIE 2 : CI/CD avancé (à venir)
- Déploiement sur serveur staging
- Analyse qualité avec SonarQube
- Pipeline multi-branches
- Tests d'intégration automatisés
- Notifications et rapports

## 🎯 Objectifs pédagogiques

À l'issue de ce lab, vous serez capable de :
- Mettre en place une infrastructure CI/CD complète
- Créer des pipelines Jenkins déclaratifs
- Intégrer différents outils DevOps (GitLab, SonarQube)
- Déployer des applications conteneurisées
- Implémenter les meilleures pratiques CI/CD

## 📦 Prérequis

### Logiciels nécessaires
- Docker Desktop (ou Docker Engine) >= 20.10
- Docker Compose >= 2.0
- 8 GB de RAM minimum (12 GB recommandé)
- 20 GB d'espace disque libre

### Connaissances préalables
- Bases de Jenkins (jobs, pipelines)
- Docker et conteneurisation (bases)
- Git et versioning
- Ligne de commande Linux/Unix

## 🚀 Démarrage rapide

### 1. Cloner le repository
```bash
git clone <url-du-repo>
cd jenkins-lab
```

### 2. Lancer l'infrastructure
```bash
# Construire et démarrer tous les services
docker-compose up -d

# Vérifier que tout fonctionne
docker-compose ps
```

### 3. Accéder aux services

| Service | URL | Credentials |
|---------|-----|-------------|
| 🔧 Jenkins | http://localhost:8080 | Voir guide |
| 🦊 GitLab | http://localhost:8090 | root / rootpassword123 |
| 📊 SonarQube | http://localhost:9000 | admin / admin |
| 🎯 Staging | http://localhost:8081 | N/A |

### 4. Suivre le guide

Consultez le guide détaillé : [**PARTIE-1-GUIDE.md**](./PARTIE-1-GUIDE.md)

## 📂 Structure du projet

```
jenkins-lab/
├── docker-compose.yml          # Infrastructure complète
├── README.md                   # Ce fichier
├── PARTIE-1-GUIDE.md          # Guide détaillé Partie 1
│
├── jenkins-slave/              # Configuration du slave Jenkins
│   └── Dockerfile
│
├── staging-server/             # Serveur de déploiement
│   ├── Dockerfile
│   └── supervisord.conf
│
└── scripts/                    # Scripts utilitaires
    ├── start.sh               # Démarrage du lab
    ├── stop.sh                # Arrêt du lab
    └── reset.sh               # Réinitialisation complète
```

## 🛠️ Commandes utiles

### Gestion de l'infrastructure

```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Voir les logs d'un service
docker-compose logs -f jenkins-master

# Redémarrer un service
docker-compose restart jenkins-master

# Reconstruire les images
docker-compose build

# Réinitialiser complètement (⚠️ supprime toutes les données)
docker-compose down -v
```

### Diagnostic et monitoring

```bash
# Vérifier l'état des conteneurs
docker-compose ps

# Vérifier l'utilisation des ressources
docker stats

# Accéder à un conteneur
docker exec -it jenkins-master bash
docker exec -it jenkins-slave bash
docker exec -it gitlab bash

# Vérifier le réseau
docker network inspect jenkins-lab_jenkins-network

# Tester la connectivité
docker exec jenkins-master ping -c 2 gitlab
```

## 🐛 Troubleshooting

### Jenkins ne démarre pas
```bash
# Vérifier les logs
docker-compose logs jenkins-master

# Récupérer le mot de passe initial
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

# Redémarrer Jenkins
docker-compose restart jenkins-master
```

### GitLab est lent ou ne démarre pas
GitLab nécessite beaucoup de ressources :
- Minimum : 4 GB de RAM
- Recommandé : 8 GB de RAM
- Temps de démarrage : 3-5 minutes

```bash
# Vérifier que GitLab est prêt
docker exec gitlab gitlab-ctl status

# Augmenter les ressources Docker si nécessaire
# (Docker Desktop > Settings > Resources)
```

### Le webhook GitLab → Jenkins ne fonctionne pas
```bash
# Vérifier la connectivité réseau
docker exec gitlab ping -c 2 jenkins-master

# Vérifier l'URL du webhook dans GitLab
# Elle doit être : http://jenkins-master:8080/project/<nom-du-job>

# Vérifier les logs GitLab
docker-compose logs gitlab | grep webhook
```

### Docker dans Jenkins Slave ne fonctionne pas
```bash
# Vérifier que le socket Docker est monté
docker exec jenkins-slave ls -l /var/run/docker.sock

# Vérifier les permissions
docker exec jenkins-slave docker ps

# Redémarrer le slave
docker-compose restart jenkins-slave
```

## 📊 Ressources utilisées

L'infrastructure complète utilise environ :
- **CPU** : 4-6 cœurs
- **RAM** : 6-8 GB
- **Disque** : 10-15 GB

Répartition approximative :
- GitLab : 3-4 GB RAM
- Jenkins Master : 1 GB RAM
- SonarQube : 1-2 GB RAM
- Autres services : 1-2 GB RAM

## 🎓 Pour les formateurs

### Durée du lab
- **Partie 1** : 2-3 heures
- **Partie 2** : 2-3 heures
- **Total** : 4-6 heures

### Points d'attention
1. Vérifier que les apprenants ont les ressources système suffisantes
2. Prévoir du temps pour le démarrage de GitLab (peut être long)
3. Insister sur l'importance des noms de conteneurs pour les webhooks
4. Préparer des snapshots Docker en cas de besoin

### Exercices supplémentaires suggérés
1. Créer un pipeline qui build plusieurs branches simultanément
2. Ajouter des tests de sécurité (Trivy, OWASP)
3. Implémenter un rollback automatique en cas d'échec
4. Créer un dashboard de monitoring

## 🤝 Contribution

Ce lab est destiné à la formation. Les suggestions d'amélioration sont les bienvenues :
- Ouvrir une issue pour signaler un problème
- Proposer des améliorations via pull request
- Partager vos retours d'expérience

## 📚 Ressources additionnelles

### Documentation officielle
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Pipeline Plugin](https://www.jenkins.io/doc/book/pipeline/docker/)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [SonarQube Integration](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-jenkins/)

### Tutoriels recommandés
- [Jenkins Pipeline Tutorial](https://www.jenkins.io/doc/pipeline/tour/hello-world/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitLab Webhook Guide](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html)

### Communautés
- [Jenkins Community](https://www.jenkins.io/participate/)
- [Docker Community](https://www.docker.com/community/)
- [GitLab Forum](https://forum.gitlab.com/)

## 📄 Licence

Ce lab est fourni à des fins éducatives. Libre d'utilisation pour la formation.

## ✉️ Support

Pour toute question ou problème :
1. Consulter le [guide de troubleshooting](#-troubleshooting)
2. Vérifier les logs : `docker-compose logs <service>`
3. Rechercher dans les issues GitHub
4. Contacter le formateur

---

**Version** : 1.0.0  
**Dernière mise à jour** : Novembre 2025

Bon lab ! 🎯
