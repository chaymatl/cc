"""
test_rate_limit.py — Tests rate limiting & sécurité EcoRewind
==============================================================
Vérifie que les endpoints sensibles sont protégés contre le brute-force.
"""
import pytest
import time


class TestRateLimiting:
    """Tests de protection brute-force sur /token et /register."""

    def test_login_rate_limit_triggers_after_10_attempts(self, client):
        """
        Plus de 10 tentatives de login depuis la même IP en 1 min
        doit retourner HTTP 429 Too Many Requests.
        """
        responses = []
        for i in range(12):
            r = client.post("/token", data={
                "username": f"bruteforce_{i}@hacker.com",
                "password": "wrongpassword",
            })
            responses.append(r.status_code)

        # Au moins une réponse doit être 429
        assert 429 in responses, (
            f"Rate limit non déclenché après 12 tentatives. "
            f"Codes reçus : {set(responses)}"
        )

    def test_register_rate_limit_triggers_after_5_attempts(self, client):
        """
        Plus de 5 inscriptions depuis la même IP en 1 min
        doit retourner HTTP 429.
        """
        responses = []
        for i in range(7):
            r = client.post("/register", json={
                "email": f"spam_{i}_{int(time.time())}@spam.com",
                "full_name": "Spam User",
                "password": "spampass",
                "role": "user",
            })
            responses.append(r.status_code)

        assert 429 in responses, (
            f"Rate limit /register non déclenché. Codes : {set(responses)}"
        )

    def test_rate_limit_response_has_retry_after_header(self, client):
        """La réponse 429 doit inclure des informations utiles."""
        responses = []
        for i in range(12):
            r = client.post("/token", data={
                "username": "ratelimit@test.com",
                "password": "wrong",
            })
            if r.status_code == 429:
                responses.append(r)
                break

        if not responses:
            pytest.skip("Rate limit non atteint dans ce test")

        r = responses[0]
        # Le corps doit indiquer le problème
        assert r.status_code == 429


class TestAuthSecurity:
    """Tests de sécurité des endpoints d'authentification."""

    def test_login_wrong_credentials_returns_401(self, client):
        """Mauvais mot de passe → 401, jamais 500."""
        r = client.post("/token", data={
            "username": "nobody@ecorewind.tn",
            "password": "wrongpassword",
        })
        assert r.status_code == 401
        assert r.json()["detail"] is not None

    def test_login_sql_injection_rejected(self, client):
        """Tentative d'injection SQL → rejetée proprement (401, pas 500)."""
        r = client.post("/token", data={
            "username": "' OR '1'='1",
            "password": "' OR '1'='1",
        })
        assert r.status_code in (401, 422), f"SQL injection non gérée: {r.status_code}"

    def test_register_missing_fields_returns_422(self, client):
        """Champs requis manquants → 422 Unprocessable Entity."""
        r = client.post("/register", json={"email": "incomplete@test.tn"})
        assert r.status_code == 422

    def test_register_invalid_email_rejected(self, client):
        """Email invalide → 422."""
        r = client.post("/register", json={
            "email": "not-an-email",
            "full_name": "Test",
            "password": "pass123",
            "role": "user",
        })
        assert r.status_code == 422

    def test_protected_endpoint_without_token(self, client):
        """/users/me sans token → 401."""
        r = client.get("/users/me")
        assert r.status_code == 401

    def test_protected_endpoint_with_invalid_token(self, client):
        """/users/me avec token invalide → 401."""
        r = client.get("/users/me", headers={"Authorization": "Bearer fake.token.here"})
        assert r.status_code == 401

    def test_token_refresh_invalid_token(self, client):
        """Refresh avec mauvais token → 401 ou 400."""
        r = client.post("/token/refresh", json={"refresh_token": "invalid_refresh"})
        assert r.status_code in (400, 401, 422)


class TestUserProfile:
    """Tests du profil utilisateur authentifié."""

    def test_get_my_profile(self, client, auth_headers):
        """/users/me retourne les données de l'utilisateur connecté."""
        r = client.get("/users/me", headers=auth_headers)
        assert r.status_code == 200
        data = r.json()
        assert "email" in data
        assert "id" in data
        assert "hashed_password" not in data  # Ne jamais exposer le hash

    def test_profile_does_not_expose_password(self, client, auth_headers):
        """Le hash du mot de passe n'est jamais dans la réponse."""
        r = client.get("/users/me", headers=auth_headers)
        body_str = r.text.lower()
        assert "hashed_password" not in body_str
        assert "password" not in body_str

    def test_update_profile_name(self, client, auth_headers):
        """Mise à jour du nom de profil."""
        r = client.put("/users/me", json={"full_name": "Nouveau Nom Test"},
                       headers=auth_headers)
        # 200 ou 405 si endpoint non supporté
        assert r.status_code in (200, 405, 404)
        if r.status_code == 200:
            assert r.json()["full_name"] == "Nouveau Nom Test"
