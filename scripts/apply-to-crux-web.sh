#!/usr/bin/env bash
# ============================================================
# apply-to-crux-web.sh
# Connecte crux_web à la même base Firebase que crux_new_final
#
# Usage (depuis n'importe où) :
#   bash <(curl -sL https://raw.githubusercontent.com/MESCHAC-creator/crux/claude/crux-repos-db-integration-Yet6b/scripts/apply-to-crux-web.sh)
# ============================================================
set -euo pipefail

BRANCH="claude/crux-repos-db-integration-Yet6b"
RAW="https://raw.githubusercontent.com/MESCHAC-creator/crux/${BRANCH}"

# ── Trouver le dossier crux_web ──────────────────────────────
if [[ -f "src/crux_web.jsx" ]]; then
  WEB_DIR="."
elif [[ -d "crux_web" && -f "crux_web/src/crux_web.jsx" ]]; then
  WEB_DIR="crux_web"
else
  echo "❌  Lance ce script depuis le dossier crux_web (ou son parent)."
  exit 1
fi
cd "$WEB_DIR"
echo "📂  Dossier crux_web : $(pwd)"

# ── 1. FirebaseService.js ────────────────────────────────────
echo "⬇️   Téléchargement de FirebaseService.js..."
curl -fsSL "${RAW}/FirebaseService.web.js" -o src/services/FirebaseService.js
echo "✅  FirebaseService.js mis à jour"

# ── 2. Import dans crux_web.jsx ─────────────────────────────
if grep -q "LocalStorageService" src/crux_web.jsx; then
  sed -i "s|from './services/LocalStorageService'|from './services/FirebaseService'|g" src/crux_web.jsx
  echo "✅  Import mis à jour dans crux_web.jsx"
else
  echo "ℹ️   Import déjà à jour dans crux_web.jsx"
fi

# ── 3. .gitignore ────────────────────────────────────────────
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo ".env" >> .gitignore
  echo "✅  .env ajouté à .gitignore"
fi

# ── 4. .env.example ─────────────────────────────────────────
curl -fsSL "${RAW}/.env.web.example" -o .env.example
echo "✅  .env.example créé"

# ── 5. .env (non commité) ────────────────────────────────────
if [[ ! -f ".env" ]]; then
  cat > .env <<'ENVEOF'
REACT_APP_FIREBASE_API_KEY=AIzaSyDfVNAL2cV47g9WHPtXsaE8_4pWFpy3-Ls
REACT_APP_FIREBASE_AUTH_DOMAIN=crux-8aa85.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=crux-8aa85
REACT_APP_FIREBASE_STORAGE_BUCKET=crux-8aa85.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=667181830171
REACT_APP_FIREBASE_APP_ID=1:667181830171:web:e51269758647343bc4e8be

REACT_APP_ZEGO_APP_ID=2042049519
REACT_APP_ZEGO_SERVER_SECRET=41fb869d2bbcb148571a22b1ad4840ae

GENERATE_SOURCEMAP=false
SKIP_PREFLIGHT_CHECK=true
DISABLE_ESLINT_PLUGIN=true
ENVEOF
  echo "✅  .env créé avec les credentials Firebase (crux-8aa85)"
else
  echo "ℹ️   .env déjà présent — vérifie qu'il contient REACT_APP_FIREBASE_*"
fi

# ── 6. Commit & Push ─────────────────────────────────────────
git add src/services/FirebaseService.js src/crux_web.jsx .gitignore .env.example
git status --short

echo ""
read -r -p "🚀  Pousser vers GitHub maintenant ? (o/N) " CONFIRM
if [[ "$CONFIRM" =~ ^[oOyY] ]]; then
  git commit -m "feat: connect to Firebase — même DB que crux_new_final (crux-8aa85)

- Switch from LocalStorage to Firebase Auth + Firestore
- Users, meetings and chat are now shared with the Flutter app
- Cross-platform schema: creatorId/organizerId + roomId/channelName"
  git push origin main
  echo ""
  echo "✅  crux_web connecté à Firebase (crux-8aa85) !"
  echo "    Les comptes et réunions sont maintenant partagés avec crux_new_final."
else
  echo "ℹ️   Commit annulé. Lance 'git commit' et 'git push' quand tu es prêt."
fi
