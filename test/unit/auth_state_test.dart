// test/unit/auth_state_test.dart
// Tests unitaires pour AuthState (état global d'authentification)
// Lancer avec : flutter test test/unit/auth_state_test.dart
//
// API réelle :
//   AuthState.loginFromBackend(Map<String, dynamic>) → crée User.fromBackend()
//   AuthState.logout() → currentUser = null
//   AuthState.authToken → String?
//   AuthState.isLoggedIn → bool (currentUser != null)
//   AuthState.isAdmin → bool (role == admin || superadmin)

import 'package:flutter_test/flutter_test.dart';
import 'package:eco_rewind/models/user_model.dart';

// Données factices backend
Map<String, dynamic> _fakeUser({
  int id = 1,
  String email = 'test@ecorewind.tn',
  String name = 'Test User',
  String role = 'citoyen',
  int points = 50,
}) => {
  'id': id,
  'email': email,
  'full_name': name,
  'role': role,
  'points': points,
  'global_score': 4.2,
  'avatar_url': '',
  'qr_code': '',
  'mfa_enabled': false,
};

void main() {
  // Reset complet avant chaque test
  setUp(() {
    AuthState.logout();
    AuthState.authToken = null;
  });

  // ── État initial ─────────────────────────────────────────────────────────────

  group('AuthState — état initial', () {
    test('isLoggedIn est false par défaut', () {
      expect(AuthState.isLoggedIn, isFalse);
    });

    test('currentUser est null par défaut', () {
      expect(AuthState.currentUser, isNull);
    });

    test('authToken est null par défaut', () {
      expect(AuthState.authToken, isNull);
    });

    test('isAdmin est false quand non connecté', () {
      expect(AuthState.isAdmin, isFalse);
    });

    test('authHeader est vide quand non connecté', () {
      expect(AuthState.authHeader, isEmpty);
    });
  });

  // ── Connexion ────────────────────────────────────────────────────────────────

  group('AuthState — connexion', () {
    test('loginFromBackend rend isLoggedIn true', () {
      AuthState.loginFromBackend(_fakeUser());
      expect(AuthState.isLoggedIn, isTrue);
    });

    test('currentUser est correctement construit depuis les données backend', () {
      AuthState.loginFromBackend(_fakeUser(
        id: 42, email: 'alice@eco.tn', name: 'Alice', role: 'citoyen',
      ));
      expect(AuthState.currentUser, isNotNull);
      expect(AuthState.currentUser!.email, equals('alice@eco.tn'));
      expect(AuthState.currentUser!.name, equals('Alice'));
      expect(AuthState.currentUser!.id, equals('42'));
    });

    test('authToken est stocké manuellement', () {
      AuthState.loginFromBackend(_fakeUser());
      AuthState.authToken = 'eyJ.fake.jwt';
      expect(AuthState.authToken, equals('eyJ.fake.jwt'));
    });

    test('authHeader inclut le Bearer token si authToken est défini', () {
      AuthState.loginFromBackend(_fakeUser());
      AuthState.authToken = 'my_token_123';
      expect(AuthState.authHeader['Authorization'], equals('Bearer my_token_123'));
    });

    test('authHeader est vide si authToken est null', () {
      AuthState.loginFromBackend(_fakeUser());
      AuthState.authToken = null;
      expect(AuthState.authHeader, isEmpty);
    });
  });

  // ── Rôles ────────────────────────────────────────────────────────────────────

  group('AuthState — rôles', () {
    test('isAdmin est true pour role admin', () {
      AuthState.loginFromBackend(_fakeUser(role: 'admin'));
      expect(AuthState.isAdmin, isTrue);
    });

    test('isAdmin est true pour role superadmin', () {
      AuthState.loginFromBackend(_fakeUser(role: 'superadmin'));
      expect(AuthState.isAdmin, isTrue);
    });

    test('isAdmin est false pour role citoyen', () {
      AuthState.loginFromBackend(_fakeUser(role: 'citoyen'));
      expect(AuthState.isAdmin, isFalse);
    });

    test('isAdmin est false pour role educator', () {
      AuthState.loginFromBackend(_fakeUser(role: 'educator'));
      expect(AuthState.isAdmin, isFalse);
    });

    test('roleDisplayName retourne le bon libellé', () {
      AuthState.loginFromBackend(_fakeUser(role: 'admin'));
      expect(AuthState.currentUser!.roleDisplayName, equals('Administrateur'));
    });
  });

  // ── Déconnexion ──────────────────────────────────────────────────────────────

  group('AuthState — déconnexion', () {
    test('logout remet isLoggedIn à false', () {
      AuthState.loginFromBackend(_fakeUser());
      expect(AuthState.isLoggedIn, isTrue);

      AuthState.logout();
      expect(AuthState.isLoggedIn, isFalse);
    });

    test('logout efface currentUser', () {
      AuthState.loginFromBackend(_fakeUser());
      AuthState.logout();
      expect(AuthState.currentUser, isNull);
    });

    test('isAdmin revient à false après logout', () {
      AuthState.loginFromBackend(_fakeUser(role: 'admin'));
      AuthState.logout();
      expect(AuthState.isAdmin, isFalse);
    });

    test('double logout ne provoque pas de crash', () {
      AuthState.logout();
      expect(() => AuthState.logout(), returnsNormally);
    });

    test('authHeader vide après logout et effacement du token', () {
      AuthState.loginFromBackend(_fakeUser());
      AuthState.authToken = 'token';
      AuthState.logout();
      AuthState.authToken = null;
      expect(AuthState.authHeader, isEmpty);
    });
  });

  // ── User.fromBackend ─────────────────────────────────────────────────────────

  group('User.fromBackend — désérialisation', () {
    test('champs obligatoires correctement mappés', () {
      final user = User.fromBackend({
        'id': 99,
        'email': 'backend@eco.tn',
        'full_name': 'Backend User',
        'role': 'citoyen',
      });
      expect(user.id, equals('99'));
      expect(user.email, equals('backend@eco.tn'));
      expect(user.name, equals('Backend User'));
      expect(user.role, equals(UserRole.citoyen));
    });

    test('valeurs manquantes tombent sur les défauts', () {
      final user = User.fromBackend({'id': 1});
      expect(user.email, equals(''));
      expect(user.name, equals('Utilisateur'));
      expect(user.points, equals(0));
      expect(user.mfaEnabled, isFalse);
    });

    test('rôle "user" est rétrocompatible avec citoyen', () {
      final user = User.fromBackend({
        'id': 5, 'email': 'old@eco.tn', 'full_name': 'Old', 'role': 'user',
      });
      expect(user.role, equals(UserRole.citoyen));
    });

    test('rôle inconnu fallback sur citoyen', () {
      final user = User.fromBackend({
        'id': 6, 'email': 'x@eco.tn', 'full_name': 'X', 'role': 'unknown_role',
      });
      expect(user.role, equals(UserRole.citoyen));
    });

    test('copyWithScore crée un nouveau User avec le nouveau score', () {
      final user = User.fromBackend({
        'id': 7, 'email': 'score@eco.tn', 'full_name': 'Score', 'role': 'citoyen',
        'global_score': 3.0,
      });
      final updated = user.copyWithScore(4.8);
      expect(updated.globalScore, equals(4.8));
      expect(updated.email, equals(user.email)); // Autres champs inchangés
    });
  });
}
