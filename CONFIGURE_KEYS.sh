#!/bin/bash

# 🔑 CRUX - CONFIGURATION DES CLÉS D'API
# Script interactif pour configurer les clés

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                 🔑 CONFIGURATION DES CLÉS D'API CRUX                  ║"
echo "║                                                                        ║"
echo "║  Ce script te guide pour configurer les clés necessaires              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Créer .env.local s'il n'existe pas
if [ ! -f ".env.local" ]; then
    echo "📝 Création de .env.local..."
    cat > .env.local << 'EOF'
# FIREBASE
FIREBASE_PROJECT_ID=crux-8aa85

# AGORA (CRITICAL)
AGORA_APP_ID=
AGORA_APP_SIGNING_KEY=

# AWS (Optionnel)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=crux-recordings-prod
AWS_S3_REGION=eu-west-1

# GOOGLE CLOUD (Optionnel)
GOOGLE_CLOUD_SPEECH_KEY=

# Jitsi (Optionnel)
JITSI_SFU_URL=https://meet.jitsi.org

# Environment
ENVIRONMENT=production
EOF
    echo "✅ .env.local créé"
else
    echo "✅ .env.local existe"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo ""

# Questions interactives
echo "1️⃣ FIREBASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Vérification Firebase..."
if [ -f "android/app/google-services.json" ]; then
    echo "✅ google-services.json trouvé (Android)"
else
    echo "❌ google-services.json MANQUE"
    echo "   À télécharger depuis: https://console.firebase.google.com"
    echo "   À placer dans: android/app/google-services.json"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist trouvé (iOS)"
else
    echo "❌ GoogleService-Info.plist MANQUE"
    echo "   À télécharger depuis: https://console.firebase.google.com"
    echo "   À placer dans: ios/Runner/GoogleService-Info.plist"
fi

echo ""
read -p "As-tu téléchargé les fichiers Firebase? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Firebase OK"
else
    echo "⚠️  À faire avant de continuer"
    echo "   https://console.firebase.google.com"
fi

echo ""
echo "2️⃣ AGORA (CRITICAL - Screen sharing)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "As-tu une clé Agora?"
echo "Obtiens-la depuis: https://console.agora.io/"
echo ""

read -p "Paste AGORA_APP_ID: " agora_app_id
read -p "Paste AGORA_APP_SIGNING_KEY: " agora_signing_key

if [ -n "$agora_app_id" ] && [ -n "$agora_signing_key" ]; then
    # Update .env.local
    sed -i.bak "s/^AGORA_APP_ID=$/AGORA_APP_ID=$agora_app_id/" .env.local
    sed -i.bak "s/^AGORA_APP_SIGNING_KEY=$/AGORA_APP_SIGNING_KEY=$agora_signing_key/" .env.local
    echo "✅ Clés Agora configurées"
else
    echo "❌ Clés Agora incomplètes"
fi

echo ""
echo "3️⃣ AWS S3 (Optionnel - Recording)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Veux-tu configurer AWS? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Obtiens les clés depuis: https://console.aws.amazon.com/"
    echo ""
    read -p "Paste AWS_ACCESS_KEY_ID: " aws_key_id
    read -p "Paste AWS_SECRET_ACCESS_KEY: " aws_secret_key
    
    if [ -n "$aws_key_id" ] && [ -n "$aws_secret_key" ]; then
        sed -i.bak "s/^AWS_ACCESS_KEY_ID=$/AWS_ACCESS_KEY_ID=$aws_key_id/" .env.local
        sed -i.bak "s/^AWS_SECRET_ACCESS_KEY=$/AWS_SECRET_ACCESS_KEY=$aws_secret_key/" .env.local
        echo "✅ Clés AWS configurées"
    fi
else
    echo "⏭️  AWS optionnel pour plus tard"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "✅ CONFIGURATION COMPLÉTÉE!"
echo ""
echo "Fichier .env.local mis à jour avec:"
grep -E "^(FIREBASE_PROJECT_ID|AGORA_APP_ID|AWS_ACCESS_KEY_ID)" .env.local | sed 's/=.*/=✅/' || echo "Vérifiez .env.local"
echo ""
echo "Prochaines étapes:"
echo "1. flutter clean"
echo "2. flutter pub get"
echo "3. flutter analyze"
echo "4. GIT PUSH!"
echo ""
