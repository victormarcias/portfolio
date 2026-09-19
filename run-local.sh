#!/bin/sh
cd "$(dirname "$0")/public"
PORT=8001

if command -v python3 >/dev/null 2>&1; then
  echo "Serving with python3 on http://localhost:$PORT"
  open "http://localhost:$PORT"
  exec python3 -m http.server "$PORT"
elif command -v php >/dev/null 2>&1; then
  echo "Serving with php on http://localhost:$PORT"
  open "http://localhost:$PORT"
  exec php -S "localhost:$PORT"
elif command -v ruby >/dev/null 2>&1; then
  echo "Serving with ruby on http://localhost:$PORT"
  open "http://localhost:$PORT"
  exec ruby -run -e httpd . -p "$PORT"
else
  echo "No python3, php, or ruby found. Install one of them to run a local server." >&2
  exit 1
fi
