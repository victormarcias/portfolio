# portfolio

Landing page personal (victormarcias.online): foto + links (LinkedIn, GitHub, CV). El sitio en sí es HTML/CSS estático, sin build — el CV es la excepción, se sirve dinámico vía Cloud Functions (ver más abajo).

## Estructura

Todo lo que se sirve públicamente vive en `public/` (coincide con el `public` de Firebase Hosting):

- `public/index.html` — la página
- `public/styles.css` — estilos
- `public/marquee.js` — arma las dos marquesinas (agencias/clientes) desde `public/clients/*.json`
- `public/cv-not-found.html` — fallback cuando el CV no está disponible en Storage (ver `/cv` abajo)
- `public/assets/photo.png` — foto de perfil (fallback a iniciales si falta)
- `public/clients/` — `agencies.json` / `clients.json` + `images/` con los logos de la marquesina
- `functions/` — Cloud Functions (`serve_cv`, `update_cv`) que arman `/cv` (fuera de `public/`, no es contenido estático)

`/rekap/**` no vive en este repo — se rutea (ver `firebase.json`) a una Cloud Function (`serve_rekap`) deployada desde el repo aparte [rekap-docs](https://github.com/victormarcias/rekap-docs), mismo mecanismo que ya usa `/cv` acá (`serve_cv`), solo que ese código vive en el otro repo.

## Correr local

```bash
./run-local.sh
```

Levanta un server real en `http://localhost:8001` (prueba `python3` → `php` → `ruby`, el primero que encuentre — así se comporta como prod, no como abrir el archivo directo).

Para cortarlo:

```bash
./stop.sh
```

## Subir a producción (victormarcias.online)

```bash
./deploy-prod.sh
```

Deploya a Firebase Hosting y las functions del CV (`serve_cv`, `update_cv`), proyecto definido en `FIREBASE_PROJECT` (`.env` en la raíz, gitignoreado — plantilla en `.env.example`), y al final corre `./update-cv.sh` para que `/cv` sirva la última versión del Google Doc (requiere el repo sin cambios sin commitear). Ese mismo proyecto también rutea `/hero-blog/**` al Cloud Run de `fastapi-blog` y `/rekap/**` a la Cloud Function `serve_rekap` de [rekap-docs](https://github.com/victormarcias/rekap-docs) (ambos repos aparte, sin relación de código con este) — así conviven bajo un solo dominio sin subdominios y sin Load Balancer.

## Update CV

El CV vive como Google Doc (público por link; su ID está en `functions/.env` como `CV_DOC_ID`, gitignoreado — la plantilla es `functions/.env.example`, y hay que re-deployar las functions si cambia) — nunca se edita un PDF a mano. El flujo:

```
Doc (editás acá) --update_cv (POST + secret)--> Cloud Storage (cv/cv.pdf) --serve_cv (GET)--> /cv
```

- **`functions/serve_cv`** — público, sirve el PDF que esté en Storage ahora mismo. Si todavía no se generó ninguno, redirige a `cv-not-found.html`.
- **`functions/update_cv`** — protegido con un secret, re-exporta el Doc a PDF y lo sube a Storage. Se llama a mano cada vez que termines de editar el Doc, con el script (lee el secret de `.cv-secret`, gitignoreado):

```bash
./update-cv.sh
```

Es equivalente a este curl:

```bash
curl -X POST "https://us-central1-<FIREBASE_PROJECT>.cloudfunctions.net/update_cv?secret=TU_SECRET"
```
