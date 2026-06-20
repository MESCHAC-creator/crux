# 🔑 CLÉS D'API REQUISES - GUIDE COMPLET

## 🚨 RÉSUMÉ RAPIDE

Tu as BESOIN de configurer **3 clés critiques**:

1. **FIREBASE** (Déjà faites?)
2. **AGORA** (CRITIQUE - Screen sharing)
3. **AWS** (Recommandé - Recording)

Plus tard (optionnel):
4. Google Cloud (Transcription)
5. Jitsi (Large conferences)

---

## 📋 LISTE COMPLÈTE - Copie-colle dans .env.local

```env
# ═══════════════════════════════════════════════════════════════════════════
# 1. FIREBASE (REQUIS)
# ═══════════════════════════════════════════════════════════════════════════

FIREBASE_PROJECT_ID=crux-8aa85
FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
FIREBASE_AUTH_DOMAIN=crux-8aa85.firebaseapp.com
FIREBASE_DATABASE_URL=https://crux-8aa85.firebaseio.com
FIREBASE_STORAGE_BUCKET=crux-8aa85.appspot.com
FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID
FIREBASE_APP_ID=YOUR_APP_ID


# ═══════════════════════════════════════════════════════════════════════════
# 2. AGORA (CRITIQUE - Screen sharing + meeting)
# Get from: https://console.agora.io/
# ═══════════════════════════════════════════════════════════════════════════

AGORA_APP_ID=YOUR_AGORA_APP_ID_HERE
AGORA_APP_SIGNING_KEY=YOUR_AGORA_SIGNING_KEY_HERE


# ═══════════════════════════════════════════════════════════════════════════
# 3. AWS S3 (RECOMMANDÉ - Recording storage)
# Get from: https://console.aws.amazon.com/
# ═══════════════════════════════════════════════════════════════════════════

AWS_ACCESS_KEY_ID=AKIA1234567890ABCDEF
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY_HERE
AWS_S3_BUCKET=crux-recordings-prod
AWS_S3_REGION=eu-west-1


# ═══════════════════════════════════════════════════════════════════════════
# 4. JITSI (OPTIONNEL - Large meetings 300+)
# ═══════════════════════════════════════════════════════════════════════════

JITSI_SFU_URL=https://meet.jitsi.org
JITSI_APP_ID=crux


# ═══════════════════════════════════════════════════════════════════════════
# 5. GOOGLE CLOUD (OPTIONNEL - Auto-transcription)
# Get from: https://console.cloud.google.com/
# ═══════════════════════════════════════════════════════════════════════════

GOOGLE_CLOUD_PROJECT_ID=crux-12345
GOOGLE_CLOUD_SPEECH_KEY=path/to/google-credentials.json


# ═══════════════════════════════════════════════════════════════════════════
# 6. ENVIRONMENT
# ═══════════════════════════════════════════════════════════════════════════

ENVIRONMENT=production
DEBUG_MODE=false
```

---

## 🎯 PRIORITÉS - Ce que tu DOIS faire:

### PRIORITÉ 1: FIREBASE ✅ (Probablement déjà fait)

**As-tu les fichiers?**
```bash
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

Si OUI: ✅ Firebase est configurée
Si NON: Télécharger depuis https://console.firebase.google.com


### PRIORITÉ 2: AGORA 🔴 (CRITIQUE - Sans ça, pas de screen sharing)

**As-tu les clés?**
- AGORA_APP_ID: ?
- AGORA_APP_SIGNING_KEY: ?

Si NON:
1. Va sur: https://console.agora.io/
2. Crée un compte
3. Crée un projet
4. Copie les clés
5. Ajoute à .env.local


### PRIORITÉ 3: AWS 🟡 (Recommandé - Pour recording)

**As-tu les clés?**
- AWS_ACCESS_KEY_ID: ?
- AWS_SECRET_ACCESS_KEY: ?

Si NON (mais optionnel):
1. Va sur: https://aws.amazon.com/
2. Crée bucket S3
3. Crée IAM user
4. Copie les clés
5. Ajoute à .env.local


### PRIORITÉ 4: Google Cloud 🟢 (Optionnel - Pour transcription)

**Besoin?** Non, peux ajouter plus tard


### PRIORITÉ 5: Jitsi 🟢 (Optionnel - Pour 300+)

**Besoin?** Non, utilise jitsi.org par défaut

---

## 🔍 VÉRIFICATION - As-tu déjà une partie?

Crée le fichier `.env.local` et mets:

```bash
cat > .env.local << 'EOF'
# Remplis ce que tu as déjà:

FIREBASE_PROJECT_ID=crux-8aa85

# As-tu Agora?
AGORA_APP_ID=

# As-tu AWS?
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=crux-recordings-prod

ENVIRONMENT=production
EOF

echo "✅ .env.local créé"
cat .env.local
```

---

## 📍 CLÉS EXACTES À COPIER-COLLER

### 1. FIREBASE

Vérifier que tu as ces 7 valeurs:
```
FIREBASE_PROJECT_ID=crux-8aa85
FIREBASE_API_KEY=???
FIREBASE_AUTH_DOMAIN=crux-8aa85.firebaseapp.com
FIREBASE_DATABASE_URL=https://crux-8aa85.firebaseio.com
FIREBASE_STORAGE_BUCKET=crux-8aa85.appspot.com
FIREBASE_MESSAGING_SENDER_ID=???
FIREBASE_APP_ID=???
```

Où les obtenir: https://console.firebase.google.com → Project Settings


### 2. AGORA (CRITIQUE!)

Tu besoin de **EXACTEMENT 2 clés**:

```
AGORA_APP_ID=abc123def456xyz...
AGORA_APP_SIGNING_KEY=xyz789...
```

Où les obtenir: https://console.agora.io/ → Project → App Certificate


### 3. AWS (Recommandé)

Tu besoin de **EXACTEMENT 4 clés**:

```
AWS_ACCESS_KEY_ID=AKIA1234567890ABCDEF
AWS_SECRET_ACCESS_KEY=xyz123...
AWS_S3_BUCKET=crux-recordings-prod
AWS_S3_REGION=eu-west-1
```

Où les obtenir: https://console.aws.amazon.com/ → IAM → Users


---

## 🚀 ÉTAPES POUR OBTENIR CHAQUE CLÉ

### FIREBASE (10 minutes)

**Déjà fait? Vérifie:**
```bash
[ -f "android/app/google-services.json" ] && echo "✅ Android OK" || echo "❌ Manque"
[ -f "ios/Runner/GoogleService-Info.plist" ] && echo "✅ iOS OK" || echo "❌ Manque"
```

**Sinon, télécharge:**
1. https://console.firebase.google.com
2. Projet: crux-8aa85
3. Settings → Download JSON (Android)
4. Settings → Download PLIST (iOS)


### AGORA (5 minutes) - CRITIQUE!

**ÉTAPE 1: Créer compte**
```
1. Va sur: https://console.agora.io/
2. Sign Up
3. Vérify email
```

**ÉTAPE 2: Créer projet**
```
1. Console → Create Project
2. Name: CRUX
3. Create
```

**ÉTAPE 3: Copier App ID**
```
1. Project Settings
2. Copy "App ID"
3. Paste dans .env.local:
   AGORA_APP_ID=...
```

**ÉTAPE 4: Générer Signing Key**
```
1. Project Settings
2. Primary Certificate (generate if needed)
3. Copy "App Certificate"
4. Paste dans .env.local:
   AGORA_APP_SIGNING_KEY=...
```

**RÉSULTAT:**
```env
AGORA_APP_ID=abc123def456
AGORA_APP_SIGNING_KEY=xyz789
```


### AWS (10 minutes) - Optionnel mais recommandé

**ÉTAPE 1: Créer bucket S3**
```
1. Va sur: https://console.aws.amazon.com/
2. S3 → Create Bucket
3. Name: crux-recordings-prod
4. Region: eu-west-1
5. Create
```

**ÉTAPE 2: Créer IAM User**
```
1. IAM → Users → Create User
2. Name: crux-app
3. Attach policy: AmazonS3FullAccess
4. Create
```

**ÉTAPE 3: Récupérer Access Key**
```
1. User → Security Credentials
2. Create Access Key
3. Download CSV
4. Copier dans .env.local:
   AWS_ACCESS_KEY_ID=AKIA...
   AWS_SECRET_ACCESS_KEY=...
```

**RÉSULTAT:**
```env
AWS_ACCESS_KEY_ID=AKIA1234567890ABCDEF
AWS_SECRET_ACCESS_KEY=abc123xyz789
AWS_S3_BUCKET=crux-recordings-prod
AWS_S3_REGION=eu-west-1
```


### GOOGLE CLOUD (optionnel)

```
1. https://console.cloud.google.com/
2. Create Project
3. Enable Speech-to-Text API
4. Create Service Account
5. Download JSON
```

**RÉSULTAT:**
```env
GOOGLE_CLOUD_SPEECH_KEY=path/to/credentials.json
```


---

## ✅ CHECKLIST - AVANT PUSH À GITHUB

Vérifie que tu as **AU MINIMUM**:

```
[ ] FIREBASE_PROJECT_ID=crux-8aa85
[ ] google-services.json dans android/app/
[ ] GoogleService-Info.plist dans ios/Runner/
[ ] AGORA_APP_ID (de https://console.agora.io/)
[ ] AGORA_APP_SIGNING_KEY (de https://console.agora.io/)
[ ] AWS_ACCESS_KEY_ID (optionnel)
[ ] AWS_SECRET_ACCESS_KEY (optionnel)
[ ] .env.local rempli avec les clés
[ ] .env.local dans .gitignore
[ ] Pas de secrets dans le code
```

Quand tout est ✅: PUSH À GITHUB


---

## 🎯 RÉSUMÉ - QUE FAIRE MAINTENANT?

### MINIMAL (pour que tout fonctionne):
1. ✅ Firebase: Vérifier que google-services.json existe
2. ✅ Agora: Obtenir 2 clés (5 min)
3. ✅ Ajouter dans .env.local

### RECOMMANDÉ:
4. ✅ AWS: Obtenir 4 clés (10 min)
5. ✅ Tester build

### OPTIONNEL (après):
6. Google Cloud (pour transcription)
7. Jitsi (pour 300+ meetings)

**TOTAL: ~15-20 minutes → PRÊT POUR GITHUB!**


---

## 📞 SI TU AS DES QUESTIONS:

Q: Dois-je ABSOLUMENT avoir Agora?
R: OUI - C'est critique pour screen sharing

Q: Dois-je ABSOLUMENT avoir AWS?
R: NON - Mais recommendé pour recording

Q: Où mettre les clés?
R: Dans .env.local (jamais dans le code!)

Q: Comment charger les clés dans l'app?
R: Via flutter_dotenv
   final key = dotenv.env['AGORA_APP_ID'];

Q: Puis-je PUSH sans les clés?
R: NON - L'app ne compilera pas sans AGORA_APP_ID

---

## 🚀 COMMANDES POUR COMMENCER

```bash
# 1. Créer .env.local
touch .env.local

# 2. Ajouter les valeurs (avec un éditeur)
nano .env.local

# 3. Vérifier qu'il est dans .gitignore
grep ".env.local" .gitignore

# 4. Tester que les clés sont chargées
flutter pub get
flutter analyze

# 5. Si OK: PUSH
git add .
git commit -m "Configure API keys"
git push
```

---

## 📊 STATUS FINAL

Avant PUSH à GitHub, assure-toi que tu as:

FIREBASE: ✅ (clés dans .env.local)
AGORA: ❌ À OBTENIR (https://console.agora.io/)
AWS: ⚠️ Optionnel (https://aws.amazon.com/)

TEMPS: ~20 minutes → PRÊT!

PUIS: Exécute la commande PUSH! 🚀
