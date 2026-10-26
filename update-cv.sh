#!/usr/bin/env bash
# Re-exports the CV Google Doc to PDF and publishes it at victormarcias.online/cv
# (calls the update_cv Cloud Function). The secret is read from .cv-secret
# (gitignored), never typed on the command line or printed.
set -euo pipefail

cd "$(dirname "$0")"
. ./lib.sh
load_env

: "${FIREBASE_PROJECT:?Definí FIREBASE_PROJECT en .env (ver .env.example)}"
URL="https://us-central1-${FIREBASE_PROJECT}.cloudfunctions.net/update_cv"

if [ ! -s .cv-secret ]; then
  echo "Falta .cv-secret: guardá ahí el valor de CV_UPDATE_SECRET (una línea)." >&2
  echo "Lo podés leer con: firebase functions:secrets:access CV_UPDATE_SECRET" >&2
  exit 1
fi

body="$(mktemp)"
trap 'rm -f "$body"' EXIT

echo "Actualizando el CV desde el Google Doc..."
code="$(curl -sS -o "$body" -w '%{http_code}' -X POST -G \
  --data-urlencode "secret=$(tr -d '\r\n' < .cv-secret)" "$URL")"

cat "$body"
echo

if [ "$code" != "200" ]; then
  echo "update_cv falló (HTTP $code)." >&2
  exit 1
fi

echo "Listo: https://victormarcias.online/cv"

# Copia el PDF publicado a career-mode (profile/cv.pdf), que lo adjunta al postularse.
# Otra ubicación: CAREER_MODE_DIR=/ruta/a/career-mode ./update-cv.sh
career_mode="${CAREER_MODE_DIR:-../career-mode}"
if [ ! -d "$career_mode/profile" ]; then
  echo "No encontré $career_mode/profile: no copié el CV a career-mode." >&2
  exit 0
fi

curl -fsSL -H 'Cache-Control: no-cache' -o "$career_mode/profile/cv.pdf" "https://victormarcias.online/cv"
echo "Copiado a $career_mode/profile/cv.pdf"
