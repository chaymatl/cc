# EcoRewind ♻️

**Plateforme intelligente et citoyenne de gestion du tri des déchets en Tunisie (Mobile, Web & IoT)**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-yellow?logo=python)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)](https://postgresql.org)
[![Firebase](https://img.shields.io/badge/Firebase-RTDB-orange?logo=firebase)](https://firebase.google.com)
[![Arduino](https://img.shields.io/badge/Arduino-ESP32-00979D?logo=arduino)](https://arduino.cc)
[![Alembic](https://img.shields.io/badge/Alembic-Migrations-red?logo=python)](https://alembic.sqlalchemy.org)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.x-ee4c2c?logo=pytorch)](https://pytorch.org)
[![Docker](https://img.shields.io/badge/Docker-Compatible-blue?logo=docker)](https://docker.com)

---

## 📱 Présentation

**EcoRewind** est une plateforme citoyenne et technologique complète conçue pour révolutionner le tri sélectif et la gestion des déchets en Tunisie. Elle associe une application multiplateforme (Flutter), un backend Robuste (FastAPI), des modèles d'Intelligence Artificielle de modération et un écosystème d'objets connectés (IoT).

### 🌟 Fonctionnalités Clés

- 🗺️ **Carte Interactive (OpenStreetMap)** : Localisation en temps réel des points de collecte triés par type (plastique, verre, métal, piles, papier, compost) et suivi GPS pour les citoyens.
- 🗑️ **Poubelles Intelligentes IoT (Arduino ESP32)** : Bornes de tri physiques dotées de caméras de scan de QR codes, de balances de précision (HX711) pour peser les dépôts, et de servomoteurs gérant l'accès sécurisé. Synchronisation instantanée des scores des utilisateurs via Firebase Realtime Database.
- 📸 **Réseau Social Citoyen & Eco-Feed** : Fil d'actualité permettant de partager ses actions de tri, d'aimer, de commenter et de s'inspirer des initiatives de la communauté.
- 🤖 **Pipeline de Modération IA Modulaire** : Modération de contenu texte et image hybride et performante (Text CNN, ResNet18, NudeNet et Detoxify/BERT) opérant de manière asynchrone via des tâches d'arrière-plan ou un Worker IA dédié.
- 💬 **Messagerie Temps Réel Intégrée** : Système de chat complet permettant les discussions privées, les conversations de groupe thématiques et la diffusion d'annonces administratives (broadcast).
- 🏆 **Gamification & Récompenses** : Historique détaillé des points accumulés par le tri, déblocage de badges sous forme de QR codes exclusifs et conversion en récompenses vertes.
- 🏢 **Intercommunalité & Dashboard Admin** : Gestion centralisée pour les communes avec coordination des syndicats intercommunaux, accords de transfert de déchets et rapports analytiques avancés.
- 🚚 **Itinéraires Collecteurs Optimisés** : Planification, traçage GPS sur carte et gestion d'étapes pour les tournées de ramassage des collecteurs de déchets.
- 🎮 **Eco-Quizz & Sensibilisation** : Jeux interactifs sur le tri sélectif avec statistiques d'impact écologique (CO₂ évité, arbres sauvés).
- 🌙 **Aesthetics Premium & Localisation** : Design en verre (glassmorphism) moderne et réactif sous Material 3, support complet du Mode Sombre et traduction complète en arabe.

---

## 🏗️ Architecture du Projet

```
EcoRewind/
├── arduino/                    # Code embarqué IoT (C++/Arduino)
│   └── lcd/
│       └── lcd.ino             # Programme ESP32 (caméra, servo, LCD, HX711, Firebase)
│
├── lib/                        # Application Flutter (Frontend Mobile/Web)
│   ├── core/                   # Utilitaires globaux et configurations
│   ├── features/               # Fonctionnalités transversales (ex: scan)
│   ├── layouts/                # Squelettes d'affichage responsifs
│   ├── models/                 # Modèles de données Dart (User, Badge, WasteRecord, etc.)
│   ├── screens/                # Écrans de l'application classés par rôles
│   │   ├── auth/               # Connexion, Inscription, Onboarding
│   │   ├── client/             # Interface Citoyen (Feed, Carte, Profil, Quizz)
│   │   ├── admin/              # Tableaux de bord, Intercommunalité, Analyses
│   │   ├── collector/          # Carte de tournée et suivi de collecte GPS
│   │   ├── educator/           # Module de formation et gestion de médias
│   │   └── messaging/          # Messagerie instantanée et discussions de groupe
│   ├── services/               # Consommation des APIs HTTP et sync Firebase
│   ├── theme/                  # Thème Material 3, gestion du Mode Sombre
│   └── widgets/                # Composants graphiques réutilisables (GlassCard...)
│
└── backend/                    # API REST & Worker IA (Python FastAPI)
    ├── app/                    # Code source de l'application FastAPI
    ├── routers/                # Endpoints de l'API (Auth, Posts, Bins, Routes, Chat...)
    ├── services/               # Logique métier et orchestrations (IA, Mail...)
    ├── moderation_ai/          # Pipeline de modération IA locale (PyTorch)
    ├── ai_worker/              # Worker IA asynchrone autonome (découplé en tâche de fond)
    ├── alembic/                # Dossier de migrations de schémas de base de données
    ├── requirements.txt        # Dépendances minimales de l'API Core
    ├── requirements-ai.txt     # Dépendances supplémentaires pour l'IA
    └── docker-compose.yml      # Orchestration multi-conteneurs (Postgres, API, Worker IA)
```

---

## 🤖 Pipeline de Modération IA

Le système propose une architecture de modération multicouche ultra-rapide (< 30ms) pour garantir la sécurité et la pertinence environnementale des publications.

| Couche | Modèle | Rôle | Latence |
| :--- | :--- | :--- | :--- |
| **0 - Règles** | Dictionnaire de mots-clés | Filtre lexical rapide (Français, Arabe, Anglais) | < 1ms |
| **1 - Text CNN** | EcoTextCNN custom (1.2 Mo) | Classification thématique (Écolo, Hors-sujet, Toxique) | ~5ms |
| **2 - BERT** | Detoxify (Multilingue) | Évaluation fine de la toxicité (discours de haine, insultes) | ~50ms |
| **3 - ResNet18** | ResNet18 fine-tuné (43 Mo) | Classification d'images (Éco, Hors-sujet, NSFW) | ~20ms |
| **4 - NudeNet** | CNN NSFW standard | Détection avancée de la nudité et violence | ~100ms |

### 🛡️ Approche Sécuritaire et Humaine

- **Politique prudente** : L'IA ne rejette jamais définitivement une publication de son propre chef afin d'éviter les faux positifs.
- **Circuit d'approbation** : Si le score d'infraction IA est supérieur ou égal à **0.30**, la publication est basculée dans le statut `pending_review` et envoyée dans la file d'attente d'un administrateur. Le post est invisible sur le feed jusqu'à validation humaine.

---

## 🚀 Installation & Lancement

### 1. Configuration de la base de données (PostgreSQL)

EcoRewind utilise **PostgreSQL** comme SGBD de production. Pour initialiser ou appliquer les migrations :

```bash
cd backend
# Lancer les migrations de structure avec Alembic
alembic upgrade head
```

---

### 2. Lancement du Backend (FastAPI)

Pour s'adapter à toutes les configurations de machines de test, le backend d'EcoRewind propose 3 modes d'exécution :

#### 🟢 Scénario 1 — API Seule (Configuration Légère)
*Utile pour un lancement rapide sans télécharger les modèles IA volumineux. La modération s'effectue via les règles de mots-clés.*
```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
# source venv/bin/activate # Linux/macOS

pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### 🟡 Scénario 2 — API + Worker IA (Développement IA Local)
*Requiert plus de ressources. Charge les modèles PyTorch en local.*
```bash
cd backend
# Activez l'environnement virtuel et installez l'API et l'IA
pip install -r requirements.txt
pip install -r requirements-ai.txt

# Terminal 1 : Lancez le serveur d'API principal
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Terminal 2 : Lancez le worker de modération IA en arrière-plan
python -m ai_worker.worker
```

#### 🔵 Scénario 3 — Docker Compose (Production prête)
*Déploie automatiquement PostgreSQL, l'interface Adminer, l'API FastAPI et le Worker IA.*
```bash
cd backend
# Lancement complet avec le worker IA
docker compose --profile ai up -d --build
```
L'API est accessible sur `http://localhost:8000` et sa documentation Swagger sur `http://localhost:8000/docs`.

---

### 3. Lancement du Frontend (Flutter)

```bash
# Récupérer les dépendances
flutter pub get

# Lancer sur Chrome (Web)
flutter run -d chrome

# Compiler le build de production Web
flutter build web
```

---

### 4. Configuration IoT (Arduino ESP32)

Le programme de la poubelle connectée est situé dans [lcd.ino](file:///c:/Users/lenovo/Desktop/EcoRewind/arduino/lcd/lcd.ino).

#### Matériel requis :
- ESP32 avec module Caméra (ex: AI-Thinker).
- Balance de pesée HX711 avec cellule de charge.
- Écran LCD I2C (adresse par défaut : `0x27`).
- Deux servomoteurs (Servo1 pour le clapet citoyen, Servo2 pour la trappe du collecteur).

#### Configuration :
Ouvrez le fichier `arduino/lcd/lcd.ino` et configurez vos identifiants :
```cpp
#define WIFI_SSID     "VOTRE_WIFI"
#define WIFI_PASSWORD "VOTRE_MOT_DE_PASSE"
#define FIREBASE_HOST "VOTRE_PROJECT_ID-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "VOTRE_CLE_SECRET_FIREBASE"
```
Téléversez le croquis à l'aide de l'IDE Arduino en installant les bibliothèques requises : `FirebaseESP32`, `ESP32QRCodeReader`, `ESP32Servo`, `HX711`, et `LiquidCrystal_I2C`.

---

## 🔑 Variables d'Environnement (`backend/.env`)

Créez un fichier `.env` dans le dossier `backend/` à partir de `.env.example` :

```env
APP_ENV=development
SECRET_KEY=votre_cle_secrete_jwt_ici
DATABASE_URL=postgresql://postgres:password@localhost:5432/ecorewind
GOOGLE_CLIENT_ID=votre_google_client_id_oauth
FIREBASE_DATABASE_URL=https://votre-projet-rtdb.europe-west1.firebasedatabase.app
ARDUINO_API_KEY=ecorewind-arduino-2025 # Clé d'API sécurisée pour l'ESP32
GEMINI_API_KEY=votre_cle_api_gemini
```

---

## 📡 API — Endpoints Principaux

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| **POST** | `/token` | Connexion utilisateur (génère access + refresh tokens JWT) |
| **POST** | `/register` | Inscription de citoyen avec génération de QR code (UUID) |
| **GET** | `/posts/feed` | Récupération paginée du feed social communautaire |
| **POST** | `/posts` | Publication d'un post (déclenche la modération IA en arrière-plan) |
| **POST** | `/qr/arduino-scan` | Soumission de dépôt citoyen par la poubelle Arduino IoT |
| **POST** | `/qr/arduino-collect` | Signalement de vidage poubelle par le collecteur Arduino IoT |
| **GET** | `/messaging/conversations` | Liste des conversations de chat actives |
| **POST** | `/messaging` | Envoi d'un message instantané (texte/image) |
| **GET** | `/collector/routes` | Liste des tournées planifiées pour le collecteur connecté |
| **PUT** | `/collector/routes/{id}/start` | Démarrage d'une tournée de ramassage (suivi GPS actif) |
| **GET** | `/intercommunality/regions` | Liste des régions et des statistiques intercommunales |
| **GET** | `/quiz/categories` | Liste des questionnaires d'éco-formation |

---

## 🧑‍💻 Rôles et Autorisations

L'application intègre un contrôle d'accès strict (RBAC) basé sur les rôles suivants :

- 🌿 **Citoyen (`user`)** : Participe au feed, consulte la carte, utilise les poubelles IoT via son badge QR, répond aux quizz et suit ses statistiques écologiques personnelles.
- 🚚 **Collecteur (`collector`)** : Gère ses tournées de ramassage pré-calculées, vide les bornes IoT pleines en s'identifiant via son code collecteur et suit sa feuille de route GPS.
- 🎓 **Éducateur (`educator`)** : Rédige des articles, crée des vidéos explicatives de formation et conçoit des quizz de sensibilisation.
- 🏢 **Administrateur Municipal (`admin`)** : Accède au dashboard global d'intercommunalité, supervise la file de modération IA en attente, planifie les tournées des collecteurs, gère les membres et administre les points de collecte de sa commune.

---

## 📦 Stack Technique Récapitulative

- **Frontend** : Flutter 3.x (Web + Mobile), Material 3, Flutter Animate, OpenStreetMap (Flutter Map).
- **Backend Core** : FastAPI (Python 3.11), SQLAlchemy ORM, Alembic (Migrations de schéma).
- **Base de données principale** : PostgreSQL.
- **Base de données IoT** : Firebase Realtime Database (RTDB).
- **Modération d'Images** : ResNet18 (fine-tuné sous PyTorch) + NudeNet.
- **Modération de Texte** : EcoTextCNN (PyTorch custom) + Detoxify (BERT multilingue).
- **Matériel IoT (Smart Bin)** : Microcontrôleur ESP32 CAM, balance HX711, servomoteurs SG90, écran LCD 16x2 I2C.

---

## 🤝 Contribution

1. **Forker** le dépôt.
2. Créer une branche fonctionnelle : `git checkout -b feature/ma-super-amelioration`.
3. Commiter vos modifications de façon explicite : `git commit -m "feat: ajout du module de tri X"`.
4. Pusher vers votre branche : `git push origin feature/ma-super-amelioration`.
5. Soumettre une **Pull Request** détaillée.

---

## 📄 Licence

Ce projet est développé dans un cadre académique et d'innovation citoyenne. Tous droits réservés.

🌱 *Conçu avec passion pour une Tunisie plus verte et connectée !*
