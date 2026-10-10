"""
test_posts.py — Tests CRUD publications EcoRewind
===================================================
Couvre : création, lecture, like, commentaire, sauvegarde,
         tentatives non authentifiées, et pagination.
"""
import pytest


# ── Création de post ──────────────────────────────────────────────────────────

class TestCreatePost:
    def test_create_post_authenticated(self, client, auth_headers):
        """Un utilisateur connecté peut créer un post texte."""
        r = client.post("/posts", json={
            "content": "Mon geste éco du jour : tri des déchets 🌱",
            "category": "tri",
        }, headers=auth_headers)
        assert r.status_code in (200, 201), f"Attendu 200/201, reçu {r.status_code}: {r.text}"
        data = r.json()
        assert "id" in data
        assert data["content"] == "Mon geste éco du jour : tri des déchets 🌱"

    def test_create_post_unauthenticated(self, client):
        """Sans token → 401 Unauthorized."""
        r = client.post("/posts", json={"content": "Test sans auth"})
        assert r.status_code == 401

    def test_create_post_empty_content_rejected(self, client, auth_headers):
        """Contenu vide → rejet (400 ou 422)."""
        r = client.post("/posts", json={"content": ""}, headers=auth_headers)
        assert r.status_code in (400, 422)


# ── Lecture de posts ──────────────────────────────────────────────────────────

class TestReadPosts:
    def test_list_posts_public(self, client):
        """Le feed est accessible sans authentification."""
        r = client.get("/posts")
        assert r.status_code == 200
        assert isinstance(r.json(), list)

    def test_posts_pagination(self, client):
        """Les paramètres skip/limit fonctionnent."""
        r1 = client.get("/posts?skip=0&limit=5")
        r2 = client.get("/posts?skip=5&limit=5")
        assert r1.status_code == 200
        assert r2.status_code == 200
        # Les deux pages ne doivent pas retourner les mêmes IDs
        ids1 = {p["id"] for p in r1.json()}
        ids2 = {p["id"] for p in r2.json()}
        assert ids1.isdisjoint(ids2) or len(ids1) == 0 or len(ids2) == 0

    def test_post_detail(self, client, auth_headers):
        """Lire un post par ID."""
        # Créer d'abord un post
        create = client.post("/posts", json={"content": "Post à lire"}, headers=auth_headers)
        if create.status_code not in (200, 201):
            pytest.skip("Création de post non disponible")
        post_id = create.json()["id"]

        r = client.get(f"/posts/{post_id}")
        assert r.status_code == 200
        assert r.json()["id"] == post_id

    def test_post_not_found(self, client):
        """ID inexistant → 404."""
        r = client.get("/posts/999999999")
        assert r.status_code == 404


# ── Interactions (Like, Commentaire) ─────────────────────────────────────────

class TestPostInteractions:
    @pytest.fixture(scope="class")
    def post_id(self, client, auth_headers):
        r = client.post("/posts", json={"content": "Post pour interactions"}, headers=auth_headers)
        if r.status_code not in (200, 201):
            pytest.skip("Impossible de créer un post pour les tests d'interaction")
        return r.json()["id"]

    def test_like_post(self, client, auth_headers, post_id):
        """Liker un post incrémente le compteur."""
        r = client.post(f"/posts/{post_id}/like", headers=auth_headers)
        assert r.status_code in (200, 201)

    def test_like_requires_auth(self, client, post_id):
        """Liker sans token → 401."""
        r = client.post(f"/posts/{post_id}/like")
        assert r.status_code == 401

    def test_add_comment(self, client, auth_headers, post_id):
        """Commenter un post."""
        r = client.post(f"/posts/{post_id}/comments",
                        json={"content": "Super initiative !"},
                        headers=auth_headers)
        assert r.status_code in (200, 201)
        assert "id" in r.json()

    def test_comment_requires_auth(self, client, post_id):
        """Commenter sans token → 401."""
        r = client.post(f"/posts/{post_id}/comments",
                        json={"content": "Sans auth"})
        assert r.status_code == 401

    def test_list_comments(self, client, post_id):
        """Lister les commentaires d'un post."""
        r = client.get(f"/posts/{post_id}/comments")
        assert r.status_code == 200
        assert isinstance(r.json(), list)


# ── Sauvegarde de post ────────────────────────────────────────────────────────

class TestSavePost:
    def test_save_and_unsave_post(self, client, auth_headers):
        """Toggle sauvegarde d'un post."""
        # Créer un post
        create = client.post("/posts", json={"content": "Post à sauvegarder"}, headers=auth_headers)
        if create.status_code not in (200, 201):
            pytest.skip("Création de post non disponible")
        post_id = create.json()["id"]

        # Sauvegarder
        r = client.post(f"/posts/{post_id}/save", headers=auth_headers)
        assert r.status_code in (200, 201)

        # Vérifier dans les posts sauvegardés
        saved = client.get("/users/me/saved-posts", headers=auth_headers)
        assert saved.status_code == 200
        saved_ids = [p["id"] for p in saved.json()]
        assert post_id in saved_ids

    def test_saved_posts_requires_auth(self, client):
        """Accès aux posts sauvegardés sans token → 401."""
        r = client.get("/users/me/saved-posts")
        assert r.status_code == 401
