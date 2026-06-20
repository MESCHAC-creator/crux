# 🔐 GUIDE COMPLET - CONFIGURATION DES CLÉS D'API

## ⏱️ RÉSUMÉ RAPIDE

Avant de PUSH à GitHub, tu DOIS configurer:

1. ✅ Firebase (déjà configurée?)
2. ❌ Agora (MANQUANT)
3. ❌ AWS S3 (MANQUANT)
4. ⚠️ Google Cloud (OPTIONNEL)

**Temps estimé: 15-30 minutes**

---

## 1️⃣ FIREBASE (Vérifier la configuration)

### Vérifier que tu as:
- [ ] Firebase project: crux-8aa85
- [ ] Android: google-services.json
- [ ] iOS: GoogleService-Info.plist

### Où les télécharger:
1. Va sur: https://console.firebase.google.com
2. Sélectionne: crux-8aa85
3. Project Settings → Download JSON (Android)
4. Project Settings → Download PLIST (iOS)
5. Placer dans:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

**Vérification**:
```bash
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

---

## 2️⃣ AGORA (IMPORTANT - Screen sharing)

### Pourquoi?
- Screen sharing de haute qualité
- Low latency (50-100ms)
- Small/medium meetings (≤300)

### Comment obtenir les clés:

**ÉTAPE 1: Créer un compte**
```
1. Va sur: https://console.agora.io/
2. Sign Up → Créer un compte
3. Email verification
```

**ÉTAPE 2: Créer un projet**
```
1. Console → Create Project
2. Project Name: CRUX
3. App Type: Real-time Engagement
4. Choose App Type: Video Call
5. Create
```

**ÉTAPE 3: Récupérer les clés**
```
1. Aller sur Project Settings
2. Copier: App ID
3. Copier: App Certificate (générer si besoin)
4. Copier dans .env.local
```

### Ajouter dans `.env.local`:
```env
AGORA_APP_ID=abc123def456...
AGORA_APP_SIGNING_KEY=xyz789...
```

### Vérifier:
```dart
// Dans lib/main.dart ou un service:
final agoraAppId = dotenv.env['AGORA_APP_ID'];
assert(agoraAppId != null, 'AGORA_APP_ID non trouvé!');
print('✅ Agora configurée: $agoraAppId');
```

---

## 3️⃣ AWS S3 (Pour recordings)

### Pourquoi?
- Stockage cloud pour les enregistrements
- Scalable (peut stocker 1000+ heures)
- ~$0.023/GB/mois

### Comment obtenir les clés:

**ÉTAPE 1: Créer un compte AWS**
```
1. Va sur: https://aws.amazon.com/
2. Create AWS Account
3. Vérify email + paiement
```

**ÉTAPE 2: Créer un bucket S3**
```
1. Console AWS → S3
2. Create Bucket
3. Name: crux-recordings-prod
4. Region: eu-west-1 (ou ta région)
5. Block public access: ON
6. Create
```

**ÉTAPE 3: Créer un IAM User**
```
1. Console AWS → IAM
2. Users → Create user
3. Username: crux-app
4. Programmatic access: ON
5. Permissions:
   - Attach policy: AmazonS3FullAccess
   - Ou custom policy (voir ci-dessous)
6. Créer
```

**ÉTAPE 4: Récupérer les clés**
```
1. Après création: Download .csv
2. Copier:
   - Access Key ID
   - Secret Access Key
3. Stocker dans .env.local
```

### Ajouter dans `.env.local`:
```env
AWS_ACCESS_KEY_ID=AKIA1234567890ABCDEF
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_S3_BUCKET=crux-recordings-prod
AWS_S3_REGION=eu-west-1
```

### ⚠️ Policy minimale recommandée:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::crux-recordings-prod",
        "arn:aws:s3:::crux-recordings-prod/*"
      ]
    }
  ]
}
```

### Vérifier:
```bash
# Tester l'accès
aws s3 ls s3://crux-recordings-prod --region eu-west-1
```

---

## 4️⃣ GOOGLE CLOUD (OPTIONNEL - Transcription)

### Pourquoi?
- Auto-transcription des réunions
- Accuracy: 85-95%
- Coût: ~$0.024/minute

### Comment obtenir:

**ÉTAPE 1: Créer un projet Google Cloud**
```
1. Va sur: https://console.cloud.google.com/
2. Create Project
3. Project Name: CRUX
4. Create
```

**ÉTAPE 2: Activer Speech-to-Text API**
```
1. APIs & Services → Library
2. Chercher: Cloud Speech-to-Text
3. Click → Enable
```

**ÉTAPE 3: Créer un service account**
```
1. APIs & Services → Credentials
2. Create Service Account
3. Name: crux-speech
4. Create
5. Grant role: Basic → Editor
```

**ÉTAPE 4: Créer une clé**
```
1. Service account → Keys
2. Add Key → JSON
3. Download JSON file
4. Renommer: google-credentials.json
5. Ajouter au projet (sécurisé!)
```

### Ajouter dans `.env.local`:
```env
GOOGLE_CLOUD_PROJECT_ID=crux-12345
GOOGLE_CLOUD_SPEECH_KEY=path/to/google-credentials.json
```

---

## 5️⃣ VÉRIFIER TOUT FONCTIONNE

### Checklist finale:

```bash
# 1. Vérifier les fichiers existent
[ -f ".env.local" ] && echo "✅ .env.local existe" || echo "❌ .env.local manque"
[ -f "android/app/google-services.json" ] && echo "✅ google-services.json existe" || echo "❌ google-services.json manque"
[ -f "ios/Runner/GoogleService-Info.plist" ] && echo "✅ GoogleService-Info.plist existe" || echo "❌ GoogleService-Info.plist manque"

# 2. Vérifier .gitignore
grep ".env.local" .gitignore && echo "✅ .env.local dans .gitignore" || echo "❌ .env.local NOT dans .gitignore"

# 3. Vérifier pas de secrets dans pubspec.yaml
grep -i "agora_app_id" pubspec.yaml && echo "❌ DANGER: Secret dans pubspec.yaml!" || echo "✅ OK"

# 4. Vérifier dépendances
flutter pub get

# 5. Vérifier analyse
flutter analyze

# 6. Test build (optionnel)
flutter build apk --release 2>&1 | head -20
```

---

## 🚀 APRÈS CONFIGURATION

Une fois que tout est configuré:

```bash
# 1. Nettoyer
flutter clean

# 2. Récupérer les dépendances
flutter pub get

# 3. Vérifier les warnings
flutter analyze

# 4. Tester
flutter test

# 5. Exécuter
flutter run

# 6. Build
flutter build apk --release
flutter build ios --release
```

---

## ⚠️ SÉCURITÉ - NE PAS OUBLIER!

### ✅ À FAIRE:
- Ajouter .env.local à .gitignore
- Ajouter google-services.json à .gitignore
- Ajouter GoogleService-Info.plist à .gitignore
- Jamais commiter les secrets
- Jamais partager les clés

### ❌ À ÉVITER:
- Secrets dans le code
- Secrets dans pubspec.yaml
- Secrets dans les messages de commit
- Secrets dans les screenshots
- Partager .env.local

---

## 📋 CHECKLIST AVANT PUSH À GITHUB

- [ ] firebase_core configuré
- [ ] Agora clés dans .env.local
- [ ] AWS clés dans .env.local
- [ ] google-services.json téléchargé
- [ ] GoogleService-Info.plist téléchargé
- [ ] .gitignore contient les secrets
- [ ] Pas de secrets dans le code
- [ ] pubspec.yaml à jour
- [ ] flutter pub get exécuté
- [ ] flutter analyze OK
- [ ] Prêt à PUSH

---

## 📞 AIDE

### Erreur: "AGORA_APP_ID not found"
```
Solution: Ajouter AGORA_APP_ID dans .env.local
```

### Erreur: "Firebase configuration not found"
```
Solution: Télécharger google-services.json et GoogleService-Info.plist
```

### Erreur: "AWS credentials invalid"
```
Solution: Vérifier AWS_ACCESS_KEY_ID et AWS_SECRET_ACCESS_KEY dans .env.local
```

### Comment charger les env vars dans le code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger .env.local
  await dotenv.load(fileName: '.env.local');
  
  // Utiliser
  final agoraKey = dotenv.env['AGORA_APP_ID'];
  final awsKey = dotenv.env['AWS_ACCESS_KEY_ID'];
  
  runApp(const MyApp());
}
```

---

## ✅ RÉSUMÉ

✅ Firebase: Déjà configuré  
❌ Agora: À faire (5 minutes)  
❌ AWS: À faire (10 minutes)  
⚠️ Google Cloud: Optionnel (5 minutes)  

**Total: 15-20 minutes pour tout configurer**

Après cela: **READY TO PUSH TO GITHUB!** 🚀
