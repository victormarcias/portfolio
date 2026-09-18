"""Cloud Functions (2nd gen) for victormarcias.online/cv.

Two functions, two concerns:
  - serve_cv:  público, GET  -> stream del PDF actual desde Cloud Storage.
  - update_cv: protegido, POST -> re-exporta el Google Doc como PDF y lo sube a Storage.

El Doc nunca se sirve directo al público; solo esta function lo lee (export
público por link) y guarda el resultado en un bucket que sí es público.
"""

import os

import requests
from firebase_functions import https_fn
from google.cloud import storage

DOC_ID = "your-google-doc-id"
BUCKET_NAME = os.environ.get(
    "CV_BUCKET_NAME"
)  # se completa después de `firebase init storage`
BLOB_PATH = "cv/cv.pdf"
MAX_CV_BYTES = 512 * 1024  # 512 KB — un CV nunca debería pesar más que esto

_storage_client = None


def _get_storage_client() -> storage.Client:
    """Cliente lazy: no autentica hasta que una request lo necesita de verdad.

    Si esto fuera una variable de módulo creada al importar (como antes),
    el análisis local de `firebase deploy` (que importa main.py sin
    credenciales) fallaría con DefaultCredentialsError.
    """
    global _storage_client
    if _storage_client is None:
        _storage_client = storage.Client()
    return _storage_client


@https_fn.on_request()
def serve_cv(req: https_fn.Request) -> https_fn.Response:
    """GET /cv -> el PDF actual, tal como está en Storage ahora mismo."""
    bucket = _get_storage_client().bucket(BUCKET_NAME)
    blob = bucket.blob(BLOB_PATH)

    if not blob.exists():
        return https_fn.Response(
            status=302,
            headers={"Location": "/cv-not-found.html"},
        )

    pdf_bytes = blob.download_as_bytes()
    return https_fn.Response(
        pdf_bytes,
        status=200,
        headers={
            "Content-Type": "application/pdf",
            "Content-Disposition": 'inline; filename="Victor-Marcias-CV.pdf"',
            "Cache-Control": "public, max-age=300",
        },
    )


@https_fn.on_request(secrets=["CV_UPDATE_SECRET"])
def update_cv(req: https_fn.Request) -> https_fn.Response:
    """POST /update_cv?secret=... -> re-exporta el Doc y actualiza Storage.

    Se llama a mano (o desde un shortcut/bookmark) cada vez que termines de
    editar el Doc. El secret evita que cualquiera dispare el export.
    """
    secret = req.args.get("secret", "")
    if not secret or secret != os.environ.get("CV_UPDATE_SECRET"):
        return https_fn.Response("Unauthorized", status=401)

    export_url = f"https://docs.google.com/document/d/{DOC_ID}/export?format=pdf"
    resp = requests.get(export_url, timeout=30)

    if resp.status_code != 200 or not resp.content.startswith(b"%PDF"):
        return https_fn.Response(
            f"El export del Doc falló (status {resp.status_code}) — ¿sigue público por link?",
            status=502,
        )

    if len(resp.content) > MAX_CV_BYTES:
        return https_fn.Response(
            f"El PDF exportado pesa {len(resp.content) / 1024:.0f}KB, "
            f"supera el límite de {MAX_CV_BYTES // 1024}KB. No se subió nada.",
            status=413,
        )

    bucket = _get_storage_client().bucket(BUCKET_NAME)
    blob = bucket.blob(BLOB_PATH)
    blob.upload_from_string(resp.content, content_type="application/pdf")

    return https_fn.Response("CV actualizado.", status=200)
