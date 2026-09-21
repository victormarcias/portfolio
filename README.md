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
./upload-2-prod.sh
```

Deploya a Firebase Hosting, proyecto `your-firebase-project-id`. Ese mismo proyecto también rutea `/hero-blog/**` al Cloud Run de `fastapi-blog` y `/rekap/**` a la Cloud Function `serve_rekap` de [rekap-docs](https://github.com/victormarcias/rekap-docs) (ambos repos aparte, sin relación de código con este) — así conviven bajo un solo dominio sin subdominios y sin Load Balancer.

## Update CV

El CV vive como Google Doc (público por link, el ID está hardcodeado en `functions/main.py`) — nunca se edita un PDF a mano. El flujo:

```
Doc (editás acá) --update_cv (POST + secret)--> Cloud Storage (cv/cv.pdf) --serve_cv (GET)--> /cv
```

- **`functions/serve_cv`** — público, sirve el PDF que esté en Storage ahora mismo. Si todavía no se generó ninguno, redirige a `cv-not-found.html`.
- **`functions/update_cv`** — protegido con un secret, re-exporta el Doc a PDF y lo sube a Storage. Se llama a mano cada vez que termines de editar el Doc:

```bash
curl -X POST "https://us-central1-your-firebase-project-id.cloudfunctions.net/update_cv?secret=TU_SECRET"
```
