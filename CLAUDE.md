# Portfolio — reglas del repo

Reglas solo de este repo. Las reglas generales de Victor (no commitear ni pushear sin su "commit", no verificar UI con el browser pane, etc.) vienen de `~/Documents/GitHub/global/CLAUDE.md` y valen acá también.

## Idioma

- Este repo está en **español a propósito**: README, comentarios, mensajes de los scripts y este archivo. Es la excepción a "repos en inglés". Mantenelo así.

## Es un repo público

- Nada de IDs ni secretos en el repo ni en su historial: nombre de proyecto de Firebase, ID del Google Doc del CV, nombre del bucket, valor de `CV_UPDATE_SECRET`. El historial ya fue reescrito para sacarlos; no los vuelvas a meter.
- Esos valores viven en archivos gitignoreados, cada uno con su plantilla: `.env` (`FIREBASE_PROJECT`), `functions/.env` (`CV_BUCKET_NAME`, `CV_DOC_ID`), `.cv-secret` (el secret, una línea) y `.firebaserc`. Nunca imprimas sus valores en el chat ni en logs.
- Antes de dar por listo un cambio que toque scripts, functions o docs, buscá con `git grep` que no se haya colado ningún ID.

## README

- El README habla **solo del portfolio**. No menciones `rekap-docs`, `hero-blog` ni otros subsitios: se linkean desde otro lado, no desde acá.

## Firebase

- `firebase.json` mantiene los rewrites de `/cv`, `/hero-blog` y `/rekap-docs` (apuntan a servicios que viven en otros repos). No los saques ni los reordenes.
- El proyecto tiene otras functions que se deployan desde otros repos. `deploy-prod.sh` deploya solo `hosting`, `functions:serve_cv` y `functions:update_cv`: nunca uses `--only functions` a secas ni `firebase deploy` sin `--only`.
- `deploy-prod.sh` exige el árbol de git limpio y al final corre `update-cv.sh`.
- El CV se genera desde un Google Doc: Doc → `update_cv` → Storage → `/cv`. Nunca se edita un PDF a mano.
- `functions/venv` no se versiona y se pierde si se reemplaza la carpeta del repo. Para recrearlo, dentro de `functions/`: `~/.pyenv/versions/3.12.4/bin/python3.12 -m venv venv` y `./venv/bin/pip install -r requirements.txt`.
- Los avisos del Flask "development server" y de Node `DEP0190` durante el deploy vienen del CLI de Firebase y son inofensivos. Lo que importa es que termine con `Deploy complete!`.
