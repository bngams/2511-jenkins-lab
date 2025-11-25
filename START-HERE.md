# 🎯 Démarrage Rapide - Lab Jenkins DevOps

## ⚡ Installation en 3 étapes

### 1️⃣ Prérequis
- Docker Desktop ou Docker Engine (version 20.10+)
- Docker Compose (version 2.0+)
- 8 GB RAM disponibles
- 20 GB espace disque

### 2️⃣ Lancer le lab
```bash
cd jenkins-lab
chmod +x scripts/*.sh
# Avec GitLab (ressource-intensive, 8GB RAM recommandé)
./scripts/start.sh gitlab

# Ou avec Gitea (léger, 4GB RAM suffisant)
./scripts/start.sh gitea

# Ou sans serveur Git (services core uniquement)
./scripts/start.sh
```

### 3️⃣ Accéder aux services
- **Jenkins**: http://localhost:8080
- **GitLab/Gitea**: http://localhost:8090 (selon votre choix)
  - GitLab: root / rootpassword123
  - Gitea: créez votre compte admin au premier démarrage
- **SonarQube**: http://localhost:9000 (admin / admin)

## 📖 Documentation

1. **PARTIE-1-GUIDE.md** - Guide détaillé complet (~2-3h)
2. **QUICK-REFERENCE.md** - Commandes utiles
3. **README.md** - Vue d'ensemble et troubleshooting

## 🎓 Parcours pédagogique

### ✅ Étape 1: Configuration (30 min)
- Démarrer l'infrastructure
- Configurer Jenkins (mot de passe, plugins)
- Connecter le slave Jenkins

### ✅ Étape 2: Test Docker (15 min)
- Créer un job de test
- Vérifier Docker-in-Docker
- Tester le plugin Docker Pipeline

### ✅ Étape 3: GitLab Integration (45 min)
- Créer un projet dans GitLab
- Configurer les webhooks
- Créer un pipeline déclenché automatiquement

### ✅ Étape 4: Pipeline Complet (60 min)
- Ajouter le code Node.js
- Configurer le Jenkinsfile
- Tester le pipeline complet
- Déployer sur staging

## 🚨 En cas de problème

```bash
# Diagnostic automatique
./scripts/diagnose.sh

# Redémarrer un service
docker-compose restart jenkins-master

# Voir les logs
docker-compose logs -f jenkins-master

# Réinitialiser complètement
./scripts/reset.sh
```

## 💡 Commandes Essentielles

```bash
# Démarrer (avec profil)
./scripts/start.sh gitlab   # Avec GitLab
./scripts/start.sh gitea    # Avec Gitea (léger)
./scripts/start.sh          # Sans serveur Git

# Arrêter
./scripts/stop.sh

# Diagnostic
./scripts/diagnose.sh

# Réinitialiser
./scripts/reset.sh

# Mot de passe Jenkins
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

# Logs en direct
docker-compose logs -f
```

## 🎯 Objectifs d'apprentissage

À la fin du lab, vous saurez:
- ✅ Déployer une infrastructure CI/CD avec Docker
- ✅ Configurer Jenkins avec des agents Docker
- ✅ Intégrer GitLab avec webhooks
- ✅ Créer des pipelines déclaratifs
- ✅ Utiliser Docker dans les pipelines
- ✅ Déployer automatiquement une application

## 📞 Support

- Consultez **PARTIE-1-GUIDE.md** pour le guide complet
- Section **Troubleshooting** dans **README.md**
- Commande de diagnostic: `./scripts/diagnose.sh`

---

**Temps estimé total**: 2-3 heures

**Bonne formation !** 🚀
