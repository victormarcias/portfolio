#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Verificando estado del repo..."
if [ -n "$(git status --porcelain)" ]; then
  echo "Hay cambios sin commitear. Commiteá o descartá antes de deployar a prod."
  exit 1
fi

echo "Deployando a Firebase Hosting (your-firebase-project-id)..."
firebase deploy --only hosting

echo ""
echo "Listo. Landing en producción:"
echo "  https://your-firebase-project-id.web.app"
