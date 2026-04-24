"""
Tests unitaires — EcoRewind Backend
======================================
Lancer avec : pytest tests/ -v
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database import Base, get_db


# ── Test DB (SQLite in-memory) ─────────────────────────────────────────────────
SQLALCHEMY_TEST_URL = "sqlite:///./test.db"
engine_test = create_engine(SQLALCHEMY_TEST_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_test)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="module")
def client():
    from main import app
    Base.metadata.create_all(bind=engine_test)
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    Base.metadata.drop_all(bind=engine_test)


# ── Health check ──────────────────────────────────────────────────────────────

def test_root(client):
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


# ── Auth ──────────────────────────────────────────────────────────────────────

def test_register_and_login(client):
    # Register
    r = client.post("/register", json={
        "email": "test@tridechet.tn",
        "full_name": "Test User",
        "password": "testpass123",
        "role": "user",
    })
    assert r.status_code == 200
    data = r.json()
    assert data["email"] == "test@tridechet.tn"

    # Login
    r = client.post("/token", data={"username": "test@tridechet.tn", "password": "testpass123"})
    assert r.status_code == 200
    data = r.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    return data["access_token"]


def test_register_duplicate(client):
    client.post("/register", json={
        "email": "dup@tridechet.tn", "full_name": "Dup",
        "password": "pass", "role": "user"})
    r = client.post("/register", json={
        "email": "dup@tridechet.tn", "full_name": "Dup2",
        "password": "pass", "role": "user"})
    assert r.status_code == 400


def test_login_wrong_password(client):
    r = client.post("/token", data={"username": "test@tridechet.tn", "password": "wrong"})
    assert r.status_code == 401


# ── Collection points ─────────────────────────────────────────────────────────

def test_collection_points_public(client):
    r = client.get("/collection-points")
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    # Seeding should have populated 10 points
    assert len(data) >= 10


def test_collection_points_filter_by_type(client):
    r = client.get("/collection-points?type=verre")
    assert r.status_code == 200
    data = r.json()
    for point in data:
        assert "verre" in point["types"]


def test_collection_points_search(client):
    r = client.get("/collection-points?search=ariana")
    assert r.status_code == 200
    data = r.json()
    assert any("ariana" in p["name"].lower() for p in data)


# ── Testimonials ──────────────────────────────────────────────────────────────

def test_testimonials_public_empty(client):
    r = client.get("/testimonials")
    assert r.status_code == 200
    assert isinstance(r.json(), list)


def test_submit_testimonial_requires_auth(client):
    r = client.post("/testimonials", json={"content": "Super appli!", "rating": 5})
    assert r.status_code == 401


# ── Stats ─────────────────────────────────────────────────────────────────────

def test_stats(client):
    r = client.get("/stats")
    assert r.status_code == 200
    data = r.json()
    for key in ("total_users", "total_posts", "total_collection_points",
                "co2_saved_kg", "trees_equivalent"):
        assert key in data


# ── Eco tips ──────────────────────────────────────────────────────────────────

def test_daily_tip(client):
    r = client.get("/tips/daily")
    assert r.status_code == 200
    data = r.json()
    assert "tip" in data
    assert "icon" in data
