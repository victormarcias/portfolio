#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
. ./lib.sh
load_env

: "${FIREBASE_PROJECT:?Definí FIREBASE_PROJECT en .env (ver .env.example)}"

echo "Verificando estado del repo..."
if [ -n "$(git status --porcelain)" ]; then
  echo "Hay cambios sin commitear. Commiteá o descartá antes de deployar a prod."
  exit 1
fi

# Solo las functions del CV (no `--only functions` a secas): serve_rekap se
# deploya desde otro repo (rekap-docs) y no debe tocarse desde acá.
echo "Deployando Hosting + functions del CV..."
firebase deploy --project "$FIREBASE_PROJECT" \
  --only hosting,functions:serve_cv,functions:update_cv

echo ""
./update-cv.sh

echo ""
echo "Listo. Landing en producción:"
echo "  https://${FIREBASE_PROJECT}.web.app"
