"""
Script de lancement local du backend EcoRewind.
Ecoute sur 127.0.0.1:8000 (loopback) au lieu de 0.0.0.0:8000
pour eviter l'erreur Windows [Errno 13] Permission denied sur socket.

Le tunnel ADB (adb reverse tcp:8000 tcp:8000) redirige
telephone:127.0.0.1:8000 -> PC:127.0.0.1:8000, donc 127.0.0.1 suffit.
"""
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="127.0.0.1",   # loopback = pas de permission Windows requise
        port=8000,
        reload=True,
        reload_excludes=["uploads"],
        log_level="info",
    )
