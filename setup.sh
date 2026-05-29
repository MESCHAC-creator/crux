#!/bin/bash

# Script de setup complet pour CRUX
# Usage: bash setup.sh

set -e

echo "═════════════════════════════════════════════════════════════════════"
echo "🚀 CRUX - Setup Complet"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

# Vérifications préalables
echo "📋 Vérification des prérequis..."

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé!"
    echo "Téléchargez Flutter depuis: https://flutter.dev/docs/get-started/install"
    exit 1
fi

if ! command -v dart &> /dev/null; then
    echo "❌ Dart n'est pas installé!"
    exit 1
fi

echo "✅ Flutter: $(flutter --version | head -1)"
echo "✅ Dart: $(dart --version)"
echo ""

# Étape 1: Nettoyer
echo "🧹 Étape 1: Nettoyage..."
flutter clean
echo "✅ Nettoyage effectué"
echo ""

# Étape 2: Télécharger les dépendances
echo "📦 Étape 2: Installation des dépendances..."
flutter pub get
echo "✅ Dépendances installées"
echo ""

# Étape 3: Installer flutterfire CLI
echo "🔧 Étape 3: Installation de FlutterFire CLI..."
flutter pub global activate flutterfire_cli
echo "✅ FlutterFire CLI installé"
echo ""

# Étape 4: Configurer Firebase
echo "🔥 Étape 4: Configuration Firebase..."
read -p "Entrez votre Firebase Project ID (ou appuyez sur Entrée pour crux-8aa85): " firebase_project
firebase_project=${firebase_project:-crux-8aa85}

flutterfire configure --project=$firebase_project
echo "✅ Firebase configuré"
echo ""

# Étape 5: Vérifier la configuration Agora
echo "🎥 Étape 5: Vérification Agora..."
if grep -q "YOUR_AGORA_APP_ID" lib/config/agora_config.dart; then
    echo "⚠️  ATTENTION: App ID Agora non configuré!"
    echo "Allez dans: lib/config/agora_config.dart"
    echo "Et remplacez 'YOUR_AGORA_APP_ID' par votre App ID depuis https://console.agora.io"
else
    echo "✅ App ID Agora configuré"
fi
echo ""

# Étape 6: Analyser le code
echo "📊 Étape 6: Analyse du code..."
flutter analyze
echo "✅ Analyse terminée"
echo ""

# Étape 7: Format du code (optionnel)
echo "🎨 Étape 7: Formatage du code..."
dart format lib/
echo "✅ Code formaté"
echo ""

echo "═════════════════════════════════════════════════════════════════════"
echo "✅ SETUP TERMINÉ!"
echo "═════════════════════════════════════════════════════════════════════"
echo ""
echo "🚀 Pour démarrer l'app:"
echo "   flutter run"
echo ""
echo "💡 Astuces:"
echo "   - Assurez-vous que votre App ID Agora est configuré"
echo "   - Connectez un appareil Android ou lancez un émulateur"
echo "   - Vérifiez que Firebase est correctement configuré"
echo ""