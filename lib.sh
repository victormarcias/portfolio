# Shared helper, sourced by deploy-prod.sh and update-cv.sh (`. ./lib.sh`).

# Loads .env (gitignored) from the current directory, if present.
load_env() {
  if [ -f .env ]; then
    set -a
    . ./.env
    set +a
  fi
}
