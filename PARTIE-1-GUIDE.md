# Lab Jenkins Avancé - PARTIE 1
## Infrastructure CI/CD avec Docker Compose

### Objectifs pédagogiques

À la fin de cette partie, les apprenants seront capables de :
- Mettre en place une infrastructure Jenkins complète avec Docker Compose
- Configurer un agent Jenkins avec Docker-in-Docker
- Intégrer GitLab avec Jenkins via webhooks
- Utiliser le plugin Docker Pipeline pour conteneuriser les builds
- Déployer sur un environnement de staging

---

## 📋 Prérequis

- Docker et Docker Compose installés
- Connaissances de base de Jenkins (acquises via le cas pratique précédent)
- 8 GB de RAM disponibles (recommandé)
- Ports disponibles : 8080, 8081, 8082, 8090, 8443, 2222, 9000, 50000

---

## 🏗️ Architecture du Lab

```
┌─────────────────────────────────────────────────────────────┐
│                      jenkins-network                         │
│                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Jenkins    │◄──►│   Jenkins    │    │   Staging    │  │
│  │   Master     │    │   Slave      │───►│   Server     │  │
│  │  :8080       │    │  (Docker)    │    │  :8081       │  │
│  └──────┬───────┘    └──────────────┘    └──────────────┘  │
│         │                                                     │
│         │  Webhook                                           │
│         ▼                                                     │
│  ┌──────────────┐    ┌──────────────┐                       │
│  │   GitLab     │    │  SonarQube   │                       │
│  │  :8090       │    │  :9000       │                       │
│  └──────────────┘    └──────────────┘                       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Composants

1. **Jenkins Master** (port 8080) : Orchestration des builds
2. **Jenkins Slave** : Agent avec Docker pour exécuter les pipelines
3. **GitLab** (port 8090) : Gestion du code source
4. **SonarQube** (port 9000) : Analyse de qualité du code
5. **Staging Server** (port 8081) : Serveur de déploiement

---

## 🚀 Étape 1 : Démarrage de l'infrastructure

### 1.1 Démarrer tous les services

```bash
# Se placer dans le répertoire du lab
cd jenkins-lab

# Démarrer tous les services
docker-compose up -d

# Vérifier que tous les conteneurs sont démarrés
docker-compose ps
```

**⏱️ Temps de démarrage estimé** : 3-5 minutes (GitLab peut prendre plus de temps)

### 1.2 Vérifier le statut des services

```bash
# Vérifier les logs Jenkins Master
docker-compose logs -f jenkins-master

# Vérifier les logs GitLab
docker-compose logs -f gitlab

# Vérifier les logs SonarQube
docker-compose logs -f sonarqube
```

### 1.3 Accès aux interfaces web

| Service | URL | Identifiants par défaut |
|---------|-----|-------------------------|
| Jenkins | http://localhost:8080/jenkins | À configurer (voir ci-dessous) |
| GitLab | http://localhost:8090 | root / rootpassword123 |
| SonarQube | http://localhost:9000 | admin / admin |
| Staging | http://localhost:8081 | N/A |

---

## 🔧 Étape 2 : Configuration initiale de Jenkins

### 2.1 Récupérer le mot de passe initial

```bash
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword
```

### 2.2 Configuration via l'interface web

1. Accéder à http://localhost:8080/jenkins
2. Coller le mot de passe initial
3. Sélectionner **"Install suggested plugins"**
4. Créer le premier utilisateur admin :
   - Username: `admin`
   - Password: `admin123`
   - Email: `admin@jenkins.local`

### 2.3 Installation des plugins supplémentaires

**Manage Jenkins** → **Manage Plugins** → **Available**

Rechercher et installer les plugins suivants :
- ✅ **Docker Pipeline**
- ✅ **GitLab Plugin**
- ✅ **SonarQube Scanner**
- ✅ **SSH Agent**
- ✅ **NodeJS Plugin**

**Important** : Cocher "Restart Jenkins when installation is complete"

---

## 🤖 Étape 3 : Configuration du Jenkins Slave

### 3.1 Ajouter le nœud agent

**Manage Jenkins** → **Manage Nodes and Clouds** → **New Node**

**Configuration** :
- Node name: `docker-agent`
- Type: ☑️ **Permanent Agent**
- Cliquer sur **Create**

**Paramètres du nœud** :
- Remote root directory: `/home/jenkins`
- Labels: `docker linux`
- Usage: `Use this node as much as possible`
- Launch method: `Launch agent by connecting it to the master`

### 3.2 Connecter l'agent (méthode automatique via Docker)

**Méthode recommandée** : Modifier le docker-compose.yml pour utiliser JNLP

Arrêter les services :
```bash
docker-compose down
```

Modifier la section `jenkins-slave` dans `docker-compose.yml` :

```yaml
jenkins-slave:
  image: jenkins/inbound-agent:latest
  container_name: jenkins-slave
  restart: unless-stopped
  volumes:
    - jenkins-slave-data:/home/jenkins
    - /var/run/docker.sock:/var/run/docker.sock
  environment:
    - JENKINS_URL=http://jenkins-master:8080
    - JENKINS_AGENT_NAME=docker-agent
    - JENKINS_SECRET=<À_RÉCUPÉRER_DEPUIS_JENKINS>
    - JENKINS_AGENT_WORKDIR=/home/jenkins
  networks:
    - jenkins-network
  depends_on:
    - jenkins-master
  user: root
```

**Récupérer le secret depuis Jenkins** :
- Aller dans le nœud créé
- Noter le secret affiché

Redémarrer :
```bash
docker-compose up -d jenkins-slave
```

### 3.3 Vérification

Dans Jenkins : **Manage Jenkins** → **Manage Nodes and Clouds**

Le nœud `docker-agent` devrait être **en ligne** avec une icône verte ✅

---

## 🐳 Étape 4 : Test du Docker-in-Docker sur le Slave

### 4.1 Créer un job de test

**Dashboard** → **New Item**
- Name: `test-docker-slave`
- Type: **Pipeline**
- Cliquer sur **OK**

### 4.2 Configuration du pipeline

Dans **Pipeline** → **Pipeline script**, coller :

```groovy
pipeline {
    agent {
        label 'docker'
    }
    
    stages {
        stage('Test Docker') {
            steps {
                script {
                    echo '=== Test des capacités Docker sur le slave ==='
                    
                    // Test 1 : Version Docker
                    sh 'docker --version'
                    
                    // Test 2 : Lister les conteneurs
                    sh 'docker ps'
                    
                    // Test 3 : Lister les images
                    sh 'docker images'
                    
                    // Test 4 : Lancer un conteneur de test
                    sh '''
                        docker run --rm alpine:latest echo "Hello from Docker in Jenkins!"
                    '''
                    
                    // Test 5 : Vérifier la connectivité réseau
                    sh '''
                        docker run --rm --network jenkins-lab_jenkins-network alpine:latest \
                        ping -c 2 jenkins-master
                    '''
                }
            }
        }
        
        stage('Test avec le plugin Docker Pipeline') {
            steps {
                script {
                    echo '=== Test du plugin Docker Pipeline ==='
                    
                    // Utilisation du DSL Docker
                    docker.image('node:20-alpine').inside {
                        sh 'node --version'
                        sh 'npm --version'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '=== Fin des tests ==='
        }
        success {
            echo '✅ Tous les tests Docker sont passés avec succès!'
        }
        failure {
            echo '❌ Échec des tests Docker'
        }
    }
}
```

### 4.3 Exécuter le build

**Cliquer sur "Build Now"**

**Résultat attendu** : 
- ✅ Build réussi avec code de sortie 0
- ✅ Les commandes Docker s'exécutent correctement
- ✅ L'image Node.js est téléchargée et utilisée

---

## 🦊 Étape 5 : Configuration de GitLab

### 5.1 Connexion à GitLab

1. Accéder à http://localhost:8090
2. Se connecter avec :
   - Username: `root`
   - Password: `rootpassword123`

### 5.2 Créer un projet de test

**Menu** → **Projects** → **Create new project** → **Create blank project**

**Configuration** :
- Project name: `sample-nodejs-app`
- Visibility: **Private**
- ☑️ Initialize repository with a README
- Cliquer sur **Create project**

### 5.3 Ajouter du code au projet

**Code** → **Repository** → **+** → **New file**

**Nom du fichier** : `app.js`

```javascript
// Simple Node.js application
const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello from GitLab CI/CD with Jenkins!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

**Nom du fichier** : `package.json`

```json
{
  "name": "sample-nodejs-app",
  "version": "1.0.0",
  "description": "Sample Node.js app for Jenkins CI/CD",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Running tests...\" && exit 0"
  },
  "keywords": ["nodejs", "jenkins", "cicd"],
  "author": "DevOps Training",
  "license": "MIT"
}
```

**Commit** les deux fichiers.

### 5.4 Créer un Access Token pour Jenkins

**User Settings** (avatar en haut à droite) → **Access Tokens**

**Configuration** :
- Token name: `jenkins-token`
- Expiration: `2025-12-31`
- Scopes: 
  - ☑️ `api`
  - ☑️ `read_repository`
  - ☑️ `write_repository`
- Cliquer sur **Create personal access token**

**⚠️ IMPORTANT** : Copier le token généré (il ne sera plus affiché)

Exemple : `glpat-xxxxxxxxxxxxxxxxxxxx`

---

## 🔗 Étape 6 : Intégration Jenkins ↔ GitLab

### 6.1 Configuration des credentials dans Jenkins

**Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials** → **Add Credentials**

**Configuration** :
- Kind: `GitLab API token`
- API token: `<coller_le_token_gitlab>`
- ID: `gitlab-token`
- Description: `GitLab Access Token`

### 6.2 Configuration de la connexion GitLab

**Manage Jenkins** → **Configure System** → **GitLab**

**Configuration** :
- Connection name: `GitLab Local`
- GitLab host URL: `http://gitlab`
- Credentials: Sélectionner `gitlab-token`
- Cliquer sur **Test Connection** → Devrait afficher "Success"

### 6.3 Créer un pipeline déclenché par GitLab

**Dashboard** → **New Item**
- Name: `gitlab-webhook-pipeline`
- Type: **Pipeline**
- Cliquer sur **OK**

**Configuration** :

**Build Triggers** :
- ☑️ **Build when a change is pushed to GitLab**
  - GitLab webhook URL: `http://jenkins-master:8080/project/gitlab-webhook-pipeline`
  - Enabled GitLab triggers: ☑️ Push Events
  - Cliquer sur **Advanced** → **Generate** (pour générer le secret token)
  - **Noter le Secret token généré**

**Pipeline** → **Pipeline script from SCM** :
- SCM: **Git**
- Repository URL: `http://gitlab/root/sample-nodejs-app.git`
- Credentials: Sélectionner `gitlab-token`
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

### 6.4 Ajouter le Jenkinsfile dans GitLab

Retourner dans GitLab : **sample-nodejs-app** → **Repository**

**+** → **New file** → `Jenkinsfile`

```groovy
pipeline {
    agent {
        label 'docker'
    }
    
    tools {
        nodejs 'node'  // Assurez-vous d'avoir configuré Node.js dans Jenkins
    }
    
    environment {
        APP_NAME = 'sample-nodejs-app'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📦 Récupération du code source depuis GitLab'
                checkout scm
            }
        }
        
        stage('Environment Info') {
            steps {
                sh '''
                    echo "=== Informations de l'environnement ==="
                    node --version
                    npm --version
                    docker --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '📚 Installation des dépendances'
                sh 'npm install'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 Exécution des tests'
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo '🐳 Construction de l\'image Docker'
                    docker.build("${APP_NAME}:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo '✅ Test de l\'image Docker'
                    docker.image("${APP_NAME}:${BUILD_NUMBER}").inside {
                        sh 'ls -la'
                        sh 'cat package.json'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline exécuté avec succès!'
            echo "Image créée : ${APP_NAME}:${BUILD_NUMBER}"
        }
        failure {
            echo '❌ Le pipeline a échoué'
        }
        always {
            echo '🧹 Nettoyage...'
            cleanWs()
        }
    }
}
```

**Ajouter aussi un Dockerfile** :

**+** → **New file** → `Dockerfile`

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

**Commit** les fichiers.

### 6.5 Configurer le Webhook dans GitLab

Dans GitLab : **Settings** → **Webhooks**

**Configuration** :
- URL: `http://jenkins-master:8080/project/gitlab-webhook-pipeline`
- Secret token: `<coller_le_secret_token_de_jenkins>`
- Trigger: ☑️ **Push events**
- Branch: `main`
- ☑️ Enable SSL verification: **Décocher** (car on est en local)

**Cliquer sur "Add webhook"**

### 6.6 Tester le webhook

**Option 1** : Cliquer sur le webhook créé → **Test** → **Push events**

**Option 2** : Modifier un fichier dans GitLab (ex: README.md) et commiter

**Résultat attendu** : 
- ✅ Un build se déclenche automatiquement dans Jenkins
- ✅ Le pipeline s'exécute jusqu'au bout
- ✅ Une image Docker est créée

---

## 📊 Étape 7 : Vérification et validation du lab

### 7.1 Checklist de validation

- [ ] Jenkins Master accessible sur http://localhost:8080
- [ ] Jenkins Slave connecté et opérationnel (icône verte)
- [ ] Le job `test-docker-slave` s'exécute avec succès
- [ ] GitLab accessible sur http://localhost:8090
- [ ] Projet `sample-nodejs-app` créé avec le code
- [ ] Webhook configuré entre GitLab et Jenkins
- [ ] Le job `gitlab-webhook-pipeline` se déclenche automatiquement
- [ ] L'image Docker est construite avec succès
- [ ] SonarQube accessible sur http://localhost:9000
- [ ] Staging server accessible sur http://localhost:8081

### 7.2 Commandes de diagnostic

```bash
# Vérifier l'état de tous les conteneurs
docker-compose ps

# Vérifier les réseaux
docker network ls | grep jenkins

# Tester la connectivité entre conteneurs
docker exec jenkins-master ping -c 2 gitlab
docker exec jenkins-master ping -c 2 sonarqube
docker exec jenkins-master ping -c 2 staging-server

# Vérifier les logs en cas de problème
docker-compose logs jenkins-master
docker-compose logs jenkins-slave
docker-compose logs gitlab

# Vérifier le socket Docker dans le slave
docker exec jenkins-slave docker ps
```

### 7.3 Troubleshooting

**Problème : Jenkins ne démarre pas**
```bash
# Vérifier les permissions du socket Docker
ls -l /var/run/docker.sock

# Redémarrer Jenkins
docker-compose restart jenkins-master
```

**Problème : GitLab trop lent**
```bash
# GitLab nécessite beaucoup de RAM (minimum 4GB recommandé)
# Augmenter la mémoire allouée à Docker si nécessaire
```

**Problème : Le webhook ne fonctionne pas**
- Vérifier que l'URL du webhook utilise bien `jenkins-master` (nom du conteneur)
- Vérifier que le secret token est correct
- Vérifier les logs de GitLab : `docker-compose logs gitlab`

---

## 🎓 Exercices pratiques pour les apprenants

### Exercice 1 : Personnaliser le pipeline
Modifier le `Jenkinsfile` pour ajouter une étape qui :
- Crée un fichier `build-info.txt` avec la date et le numéro de build
- Archive ce fichier en tant qu'artefact Jenkins

### Exercice 2 : Notification de build
Ajouter une notification dans le `post` section qui affiche un message différent selon le résultat du build.

### Exercice 3 : Utiliser le plugin Docker Pipeline
Créer un nouveau stage qui :
- Lance plusieurs conteneurs simultanément (ex: Node.js et Python)
- Exécute une commande dans chacun

---

## 📝 Points clés à retenir

1. **Docker-in-Docker** : Le slave Jenkins a accès au daemon Docker via le socket monté
2. **Réseau Docker** : Tous les conteneurs sont sur le même réseau et peuvent communiquer via leurs noms
3. **Webhooks** : GitLab peut déclencher automatiquement des builds Jenkins
4. **Plugin Docker Pipeline** : Permet d'utiliser Docker de manière déclarative dans les pipelines
5. **Infrastructure as Code** : Toute l'infra est définie dans `docker-compose.yml`

---

## 🎯 Prochaines étapes (Partie 2)

Dans la partie suivante, nous allons :
- Déployer l'application sur le serveur de staging
- Intégrer SonarQube pour l'analyse de code
- Mettre en place un pipeline multi-branches
- Implémenter des tests d'intégration avec Docker Compose
- Ajouter des notifications (Slack/Email)

---

## 🧹 Nettoyage du lab

Pour arrêter et supprimer tous les conteneurs :

```bash
# Arrêter tous les services
docker-compose down

# Supprimer aussi les volumes (attention: supprime toutes les données)
docker-compose down -v

# Nettoyer les images Docker créées
docker image prune -a
```

---

## 📚 Ressources complémentaires

- [Documentation Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Pipeline Plugin](https://www.jenkins.io/doc/book/pipeline/docker/)
- [GitLab CI/CD Integration](https://docs.gitlab.com/ee/integration/jenkins.html)
- [Best Practices for Jenkins](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)

---

**Durée estimée de la Partie 1** : 2-3 heures

Bon courage à vos apprenants ! 🚀
