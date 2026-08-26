# portfolio

Landing page personal (victormarcias.online): foto + links (LinkedIn, GitHub, CV). HTML/CSS estático, sin build ni dependencias — solo lo necesario para levantarlo local y subirlo a prod.

## Estructura

- `index.html` — la página
- `styles.css` — estilos
- `assets/photo.png` — foto de perfil (fallback a iniciales si falta)
- `assets/cv.pdf` — CV descargable

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

Deploya a Firebase Hosting, proyecto `your-firebase-project-id`. Ese mismo proyecto también rutea `/hero-blog/**` al Cloud Run de `fastapi-blog` (repo aparte, sin relación de código con este) — así conviven bajo un solo dominio sin subdominios y sin Load Balancer.
