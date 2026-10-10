"""
conftest.py — Fixtures partagées pour tous les tests EcoRewind
==============================================================
Lance avec : cd backend && pytest tests/ -v --tb=short
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database import Base, get_db

# ── Base SQLite in-memory isolée par session de test ──────────────────────────
SQLALCHEMY_TEST_URL = "sqlite:///./test_ecorewind.db"
engine_test = create_engine(
    SQLALCHEMY_TEST_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_test)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="session")
def client():
    from main import app
    Base.metadata.create_all(bind=engine_test)
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    Base.metadata.drop_all(bind=engine_test)


@pytest.fixture(scope="session")
def auth_token(client):
    """Crée un utilisateur test et retourne son JWT."""
    client.post("/register", json={
        "email": "fixture@ecorewind.tn",
        "full_name": "Fixture User",
        "password": "Fixture@123",
        "role": "user",
    })
    r = client.post("/token", data={
        "username": "fixture@ecorewind.tn",
        "password": "Fixture@123",
    })
    assert r.status_code == 200, f"Login fixture échoué : {r.text}"
    return r.json()["access_token"]


@pytest.fixture(scope="session")
def auth_headers(auth_token):
    """Headers Bearer prêts à l'emploi."""
    return {"Authorization": f"Bearer {auth_token}"}


@pytest.fixture(scope="session")
def admin_token(client):
    """Crée un admin test et retourne son JWT."""
    client.post("/register", json={
        "email": "admin@ecorewind.tn",
        "full_name": "Admin Test",
        "password": "Admin@123",
        "role": "admin",
    })
    r = client.post("/token", data={
        "username": "admin@ecorewind.tn",
        "password": "Admin@123",
    })
    assert r.status_code == 200
    return r.json()["access_token"]


@pytest.fixture(scope="session")
def admin_headers(admin_token):
    return {"Authorization": f"Bearer {admin_token}"}
