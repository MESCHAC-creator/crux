#!/bin/bash
set -e

echo "🔧 Configuration du build Crux..."

# Donner les permissions d'exécution
chmod +x android/gradlew
chmod +x android/gradlew.bat

# Vérifier les permissions
ls -la android/gradlew

echo "✅ Permissions configurées"

# Nettoyer et builder
flutter clean
flutter pub get
flutter build apk --release

echo "✅ Build complété!"
