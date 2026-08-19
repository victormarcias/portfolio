# cv-landing-page

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

Levanta un server real en `http://localhost:8080` (prueba `python3` → `php` → `ruby`, el primero que encuentre — así se comporta como prod, no como abrir el archivo directo).

Para cortarlo:

```bash
./stop.sh
```

## Subir a producción (victormarcias.online)

Pendiente: `upload-prod.sh` (a definir).
