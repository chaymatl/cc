import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/user_model.dart';
import '../core/cache_service.dart';
import 'fcm_service.dart';
import 'notification_service.dart';


/// Service d'authentification
/// Gere la connexion, l'inscription et la gestion des utilisateurs
class AuthService {
  static final String baseUrl = ApiConstants.baseUrl;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── Client HTTP persistant avec timeout global ──────────────────────────────
  // Tous les appels réseau passent par _http + .timeout(_kTimeout)
  // Evite de bloquer l'UI si le serveur est lent ou injoignable
  static final http.Client _http = http.Client();
  static const Duration _kTimeout = Duration(seconds: 15);

  // Web client ID du projet Firebase EcoRewind (client_type: 3)
  // Obtenu automatiquement depuis google-services.json après activation de
  // Google dans Firebase Auth > Sign-in method.
  static const String _webClientId = '539828926028-a2m18h48leoaqqelr3pejlf811rg0urf.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Android : serverClientId (Web client ID) requis pour obtenir un idToken
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // ===========================================
  // AUTHENTIFICATION
  // ===========================================

  /// Connexion avec email et mot de passe
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'mfa_required') {
          return {
            'success': true,
            'mfa_required': true,
            'mfa_token': data['mfa_token'],
            'id': data['id'],
            'email': data['email'],
          };
        }
        await _saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _saveRefreshToken(data['refresh_token']);
        }
        // Connexion Firebase pour que les Security Rules reconnaissent l'utilisateur
        await _signInToFirebase(data['firebase_token']);
        return {
          'success': true,
          'token': data['access_token'],
          'role': data['role'],
          'id': data['id'],
          'full_name': data['full_name'],
          'email': data['email'],
          'avatar_url': data['avatar_url'] ?? '',
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register(String email, String fullName, String password) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'full_name': fullName,
          'password': password,
          'role': 'citoyen',
        }),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Erreur d\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Envoie un code OTP par email ou SMS
  Future<Map<String, dynamic>> sendOTP(String identifier, {String method = 'email'}) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier, 'method': method}),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      final error = json.decode(response.body);
      return {'success': false, 'message': error['detail'] ?? 'Erreur d\'envoi OTP'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Vérifie un code OTP et retourne un token si succès
  Future<Map<String, dynamic>> verifyOTP(String identifier, String code) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier, 'code': code}),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // Si le backend retourne un firebase_token (compte vérifié avec token JWT)
        if (data['firebase_token'] != null) {
          await _signInToFirebase(data['firebase_token']);
        }
        return data;
      }
      final error = json.decode(response.body);
      return {'success': false, 'message': error['detail'] ?? 'Code invalide'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Valide la connexion MFA avec le code à 6 chiffres
  Future<Map<String, dynamic>> verifyMfaLogin(String mfaToken, String code) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/auth/mfa/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mfa_token': mfaToken,
          'code': code,
        }),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        await _saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _saveRefreshToken(data['refresh_token']);
        }
        if (data['firebase_token'] != null) {
          await _signInToFirebase(data['firebase_token']);
        }
        return {
          'success': true,
          'token': data['access_token'],
          'role': data['role'],
          'id': data['id'],
          'full_name': data['full_name'],
          'email': data['email'],
          'qr_code': data['qr_code'] ?? '',
          'avatar_url': data['avatar_url'] ?? '',
        };
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': error['detail'] ?? 'Code MFA incorrect ou expiré'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Initialise la configuration MFA sur le profil utilisateur
  Future<Map<String, dynamic>> setupMfa() async {
    try {
      final token = await _getToken();
      final response = await _http.post(
        Uri.parse('$baseUrl/users/me/mfa/setup'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'secret': data['secret'],
          'otpauth_url': data['otpauth_url'],
        };
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': error['detail'] ?? 'Erreur d\'initialisation du MFA'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Valide et active la MFA avec le premier code de l'application
  Future<Map<String, dynamic>> verifyEnableMfa(String code) async {
    try {
      final token = await _getToken();
      final response = await _http.post(
        Uri.parse('$baseUrl/users/me/mfa/verify-enable'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'code': code}),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'message': data['message'],
          'mfa_enabled': data['mfa_enabled'],
        };
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': error['detail'] ?? 'Code MFA invalide'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Désactive le MFA de façon sécurisée (avec mot de passe ou code)
  Future<Map<String, dynamic>> disableMfa({String? password, String? code}) async {
    try {
      final token = await _getToken();
      final response = await _http.post(
        Uri.parse('$baseUrl/users/me/mfa/disable'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (password != null) 'password': password,
          if (code != null) 'code': code,
        }),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'message': data['message'],
          'mfa_enabled': data['mfa_enabled'],
        };
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': error['detail'] ?? 'Erreur lors de la désactivation du MFA'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }


  bool _isGoogleSignInInProgress = false;

  /// Connexion avec Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    if (_isGoogleSignInInProgress) return {'success': false, 'message': 'Opération déjà en cours'};
    _isGoogleSignInInProgress = true;
    try {
      // Déconnecter la session précédente pour forcer le sélecteur de compte
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Connexion annulée'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      final String? tokenToSend = idToken ?? accessToken;

      if (tokenToSend == null) {
        return {'success': false, 'message': 'Erreur Google Token'};
      }

      final response = await _http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': tokenToSend}),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'mfa_required') {
          return {
            'success': true,
            'mfa_required': true,
            'mfa_token': data['mfa_token'],
            'id': data['id'],
            'email': data['email'],
          };
        }
        await _saveToken(data['access_token']);
        // Connexion Firebase pour que les Security Rules reconnaissent l'utilisateur
        await _signInToFirebase(data['firebase_token']);
        return {
          'success': true,
          'token': data['access_token'],
          'role': data['role'],
          'id': data['id'],
          'full_name': data['full_name'],
          'email': data['email'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': errorData['detail'] ?? 'Erreur Google Auth'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur Google Sign In : $e'};
    } finally {
      _isGoogleSignInInProgress = false;
    }
  }

  bool _isFacebookSignInInProgress = false;

  /// Connexion avec Facebook
  Future<Map<String, dynamic>> signInWithFacebook() async {
    if (_isFacebookSignInInProgress) {
      return {'success': false, 'message': 'Opération déjà en cours'};
    }
    _isFacebookSignInInProgress = true;
    try {
      developer.log('[FB-AUTH] Début connexion Facebook...', name: 'FacebookAuth');

      // Sur Android/iOS, déconnecter la session précédente
      // Sur web, on skip le logOut car il peut bloquer
      try {
        await FacebookAuth.instance.logOut();
        developer.log('[FB-AUTH] Session précédente déconnectée', name: 'FacebookAuth');
      } catch (e) {
        developer.log('[FB-AUTH] logOut ignoré: $e', name: 'FacebookAuth');
      }

      developer.log('[FB-AUTH] Ouverture dialog de connexion Facebook...', name: 'FacebookAuth');

      // Déclencher la boîte de dialogue de connexion Facebook avec timeout
      // dialogOnly = forcer le dialogue web au lieu de réutiliser la session de l'app Facebook
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          developer.log('[FB-AUTH] Timeout - la connexion a pris trop de temps', name: 'FacebookAuth');
          return LoginResult(status: LoginStatus.failed, message: 'Timeout: la connexion Facebook a pris trop de temps');
        },
      );

      developer.log('[FB-AUTH] Status login: ${loginResult.status}', name: 'FacebookAuth');

      // Cas 1 : L'utilisateur a annulé
      if (loginResult.status == LoginStatus.cancelled) {
        developer.log('[FB-AUTH] Connexion annulée par l\'utilisateur', name: 'FacebookAuth');
        return {'success': false, 'message': 'Connexion annulée'};
      }

      // Cas 2 : Erreur retournée par le SDK Facebook
      if (loginResult.status == LoginStatus.failed) {
        final fbError = loginResult.message ?? 'Erreur inconnue';
        developer.log('[FB-AUTH] Erreur SDK Facebook: $fbError', name: 'FacebookAuth');
        return {
          'success': false,
          'message': 'Erreur Facebook SDK : $fbError',
          'is_fb_sdk_error': true,
        };
      }

      // Cas 3 : Succès - récupération du token
      if (loginResult.status != LoginStatus.success) {
        developer.log('[FB-AUTH] Statut inattendu: ${loginResult.status}', name: 'FacebookAuth');
        return {
          'success': false,
          'message': 'Statut Facebook inattendu : ${loginResult.status}',
        };
      }

      final AccessToken? accessToken = loginResult.accessToken;
      if (accessToken == null) {
        developer.log('[FB-AUTH] accessToken est null!', name: 'FacebookAuth');
        return {'success': false, 'message': 'Token Facebook introuvable'};
      }

      developer.log('[FB-AUTH] Token Facebook obtenu. Envoi au backend...', name: 'FacebookAuth');
      developer.log('[FB-AUTH] URL backend: $baseUrl/auth/facebook', name: 'FacebookAuth');

      // Essayer l'URL principale (émulateur ou localhost)
      http.Response? response;
      String? networkError;

      try {
        response = await http
            .post(
              Uri.parse('$baseUrl/auth/facebook'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'access_token': accessToken.tokenString}),
            )
            .timeout(const Duration(seconds: 15));
        developer.log('[FB-AUTH] Réponse backend: ${response.statusCode}', name: 'FacebookAuth');
      } catch (e) {
        networkError = e.toString();
        developer.log('[FB-AUTH] Échec URL principale ($baseUrl): $networkError', name: 'FacebookAuth');

        // Fallback: essayer l'IP de l'appareil physique
        final fallbackUrl = ApiConstants.physicalDeviceUrl;
        developer.log('[FB-AUTH] Tentative fallback: $fallbackUrl/auth/facebook', name: 'FacebookAuth');
        try {
          response = await http
              .post(
                Uri.parse('$fallbackUrl/auth/facebook'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'access_token': accessToken.tokenString}),
              )
              .timeout(const Duration(seconds: 15));
          developer.log('[FB-AUTH] Fallback réussi! Réponse: ${response.statusCode}', name: 'FacebookAuth');
        } catch (e2) {
          developer.log('[FB-AUTH] Fallback échoué aussi: $e2', name: 'FacebookAuth');
          return {
            'success': false,
            'message': 'Serveur inaccessible. Vérifiez que le backend est démarré.',
            'is_network_error': true,
          };
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'mfa_required') {
          return {
            'success': true,
            'mfa_required': true,
            'mfa_token': data['mfa_token'],
            'id': data['id'],
            'email': data['email'],
          };
        }
        await _saveToken(data['access_token']);
        // Connexion Firebase pour que les Security Rules reconnaissent l'utilisateur
        await _signInToFirebase(data['firebase_token']);
        developer.log('[FB-AUTH] ✅ Connexion Facebook réussie pour ${data['email']}', name: 'FacebookAuth');
        return {
          'success': true,
          'token': data['access_token'],
          'role': data['role'],
          'id': data['id'],
          'full_name': data['full_name'],
          'email': data['email'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final detail = errorData['detail'] ?? 'Erreur du serveur Facebook Auth';
        developer.log('[FB-AUTH] ❌ Erreur backend (${response.statusCode}): $detail', name: 'FacebookAuth');
        return {
          'success': false,
          'message': detail,
          'is_backend_error': true,
          'status_code': response.statusCode,
        };
      }
    } on Exception catch (e) {
      final errStr = e.toString();
      developer.log('[FB-AUTH] Exception inattendue: $errStr', name: 'FacebookAuth');
      return {
        'success': false,
        'message': 'Erreur réseau Facebook : $errStr',
        'is_network_error': true,
      };
    } finally {
      _isFacebookSignInInProgress = false;
    }
  }

  // ===========================================
  // MOT DE PASSE
  // ===========================================

  /// Demande de reinitialisation du mot de passe
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['detail'] ?? 'Succès',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Vérifie le code de réinitialisation sans le consommer
  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code}),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['detail'] ?? 'Erreur',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Reinitialisation du mot de passe avec le token
  /// Retourne aussi access_token + user info pour auto-login
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'new_password': newPassword,
        }),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        // Sauvegarder le token JWT si le backend le retourne (auto-login)
        if (data['access_token'] != null) {
          await _saveToken(data['access_token']);
          await _signInToFirebase(data['firebase_token']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Succès',
          'access_token': data['access_token'],
          'role': data['role'],
          'id': data['id'],
          'full_name': data['full_name'],
          'email': data['email'],
          'avatar_url': data['avatar_url'] ?? '',
          'qr_code': data['qr_code'] ?? '',
        };
      }
      return {
        'success': false,
        'message': data['detail'] ?? data['message'] ?? 'Erreur',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }


  /// Change le mot de passe de l'utilisateur connecte
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final token = await _getToken();
      final response = await _http.post(
        Uri.parse('$baseUrl/users/me/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['detail'] ?? 'Erreur lors du changement de mot de passe',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // ===========================================
  // FIREBASE AUTH — CUSTOM TOKEN
  // ===========================================

  /// Connecte l'utilisateur à Firebase via un Custom Token généré par FastAPI.
  ///
  /// Pourquoi : Firebase Realtime Database Security Rules utilisent auth.uid
  /// pour identifier l'utilisateur. Sans cette étape, Flutter ne peut pas lire
  /// /scores/{user_id} (les règles refusent les requêtes non authentifiées).
  ///
  /// Le firebase_token est généré par FastAPI (Admin SDK) lors du login et
  /// correspond à uid = str(user_id) dans PostgreSQL.
  ///
  /// Mode noop : si firebase_token est null (Firebase indisponible côté backend),
  /// on log un avertissement mais l'app continue normalement.
  Future<void> _signInToFirebase(String? firebaseToken) async {
    if (firebaseToken == null || firebaseToken.isEmpty) {
      developer.log(
        '[Firebase] Custom token absent — scores temps réel désactivés',
        name: 'AuthService',
      );
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      developer.log(
        '[Firebase] ✅ signInWithCustomToken réussi — uid: ${FirebaseAuth.instance.currentUser?.uid}',
        name: 'AuthService',
      );
    } catch (e) {
      developer.log(
        '[Firebase] ⚠ï¸ signInWithCustomToken échoué (mode dégradé) : $e',
        name: 'AuthService',
      );
      // On ne throw pas — l'app continue sans temps réel Firebase
    }
  }

  // ===========================================
  // STOCKAGE DU TOKEN — Android Keystore / iOS Keychain
  // jwt_token + refresh_token → flutter_secure_storage (chiffré matériel)
  // Données FCM non-sensibles → SharedPreferences (pas de clés secrètes)
  // ===========================================

  /// Instance unique FlutterSecureStorage avec options robustes
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(), // AES-256 via custom ciphers (Android Keystore)
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _kJwt     = 'jwt_token';
  static const _kRefresh = 'refresh_token';

  /// Migration transparente : si l'ancien token est dans SharedPreferences,
  /// le déplacer vers le stockage sécurisé (appel unique au premier lancement).
  static Future<void> migrateTokensIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Migrer jwt_token
      final oldJwt = prefs.getString(_kJwt);
      if (oldJwt != null) {
        await _secureStorage.write(key: _kJwt, value: oldJwt);
        await prefs.remove(_kJwt);
        developer.log('[SecureStorage] jwt_token migré depuis SharedPreferences → Keystore', name: 'AuthService');
      }
      // Migrer refresh_token
      final oldRefresh = prefs.getString(_kRefresh);
      if (oldRefresh != null) {
        await _secureStorage.write(key: _kRefresh, value: oldRefresh);
        await prefs.remove(_kRefresh);
        developer.log('[SecureStorage] refresh_token migré depuis SharedPreferences → Keystore', name: 'AuthService');
      }
    } catch (e) {
      developer.log('[SecureStorage] Migration ignorée : $e', name: 'AuthService');
    }
  }

  /// Sauvegarde le token JWT dans le Keystore Android / Keychain iOS et SharedPreferences
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _kJwt, value: token);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kJwt, token);
    } catch (_) {}
    // Synchroniser avec AuthState pour accès synchrone dans l'app
    AuthState.authToken = token;
    // ── Envoyer le token FCM au backend maintenant qu'on est connecté ────────
    _sendFcmTokenAfterLogin();
  }

  /// Envoie le token FCM après connexion (sans bloquer le flux principal)
  void _sendFcmTokenAfterLogin() {
    // Léger délai pour laisser Firebase Auth se stabiliser
    Future.delayed(const Duration(milliseconds: 800), () async {
      try {
        await FcmService.onUserLoggedIn();
        debugPrint('[FCM] Token FCM enregistré avec succès après login');
      } catch (e) {
        debugPrint('[FCM] Erreur envoi token après login: $e');
      }
    });
  }


  /// Public alias for saving token (used by OTP verification)
  Future<void> saveToken(String token) => _saveToken(token);

  /// Récupère le token JWT (synchrone AuthState puis stockage sécurisé)
  Future<String?> getToken() async => AuthState.authToken ?? await _getToken();

  /// Sauvegarde le refresh token dans le stockage sécurisé
  Future<void> _saveRefreshToken(String token) async {
    await _secureStorage.write(key: _kRefresh, value: token);
  }

  /// Récupère le token JWT depuis le stockage sécurisé
  Future<String?> _getToken() async {
    return _secureStorage.read(key: _kJwt);
  }

  /// Récupère le refresh token depuis le stockage sécurisé
  Future<String?> _getRefreshToken() async {
    return _secureStorage.read(key: _kRefresh);
  }

  /// Tente de renouveler le token d'accès via le refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _http.post(
        Uri.parse('$baseUrl/token/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _saveRefreshToken(data['refresh_token']);
        }
        developer.log('Token renouvelé avec succès', name: 'AuthService');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Erreur refresh token: $e', name: 'AuthService');
      return false;
    }
  }

  /// Effectue un GET authentifié avec auto-refresh en cas de 401
  Future<http.Response> authenticatedGet(String url) async {
    final token = await _getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    var response = await _http.get(Uri.parse(url), headers: headers).timeout(_kTimeout);

    // Si 401 → tenter un refresh puis re-essayer
    if (response.statusCode == 401 && token != null) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await _getToken();
        headers['Authorization'] = 'Bearer $newToken';
        response = await _http.get(Uri.parse(url), headers: headers).timeout(_kTimeout);
      }
    }
    return response;
  }

  /// Supprime tous les tokens sensibles (déconnexion JWT + Firebase)
  Future<void> clearTokens() async {
    // ── Sauvegarder le timestamp de déconnexion dans SharedPreferences ────────
    // (donnée non-sensible : utilisée par FCM pour filtrer les notifications)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'fcm_last_logout_time',
      DateTime.now().toUtc().toIso8601String(),
    );
    await prefs.remove('fcm_shown_notif_ids');
    await prefs.remove('fcm_last_sent_token');

    // ── Effacer les tokens sensibles du Keystore/Keychain ─────────────────────
    await _secureStorage.delete(key: _kJwt);
    await _secureStorage.delete(key: _kRefresh);
    AuthState.authToken = null;

    // ── Déconnexion Firebase ──────────────────────────────────────────────────
    try {
      await FirebaseAuth.instance.signOut();
      developer.log('[Firebase] ✅ Déconnexion Firebase réussie', name: 'AuthService');
    } catch (e) {
      developer.log('[Firebase] ⚠ï¸ Erreur déconnexion Firebase : $e', name: 'AuthService');
    }
  }


  /// Recupere les details de l'utilisateur actuel depuis le backend
  Future<Map<String, dynamic>> getCurrentUserDetails() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Aucun token'};

      final response = await authenticatedGet('$baseUrl/users/me');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'user': data,
        };
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide — NE PAS supprimer les tokens localement
        // (le refresh a déjà été tenté par authenticatedGet)
        // Retourner l'erreur sans déconnecter l'utilisateur
        return {'success': false, 'message': 'Session expirée'};
      } else {
        return {'success': false, 'message': 'Erreur serveur: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // ===========================================
  // SYNCHRONISATION DES PUBLICATIONS
  // ===========================================

  /// Recupere les publications avec pagination (avec etat liked/saved si connecte)
  Future<List<dynamic>> fetchPosts({int skip = 0, int limit = 15}) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      
      // Use /posts/feed when authenticated (returns is_liked/is_saved)
      String endpoint = '$baseUrl/posts?skip=$skip&limit=$limit';
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        endpoint = '$baseUrl/posts/feed?skip=$skip&limit=$limit';
      }
      
      final response = await _http.get(Uri.parse(endpoint), headers: headers).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      // If /posts/feed fails (401), fallback to /posts
      if (token != null && response.statusCode == 401) {
        final fallback = await _http.get(Uri.parse('$baseUrl/posts?skip=$skip&limit=$limit')).timeout(_kTimeout);
        if (fallback.statusCode == 200) {
          return json.decode(utf8.decode(fallback.bodyBytes));
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Alias — loads all posts (first page, large limit)
  @Deprecated('Use fetchPosts(skip, limit) for pagination instead')
  Future<List<dynamic>> fetchAllPosts() => fetchPosts(skip: 0, limit: 50);

  // ===========================================
  // NOTIFICATIONS
  // ===========================================

  /// Récupère les notifications de l'utilisateur
  Future<List<dynamic>> fetchNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final response = await _http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> fetchUnreadCount() async {
    try {
      final token = await _getToken();
      if (token == null) return 0;
      final response = await _http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Marque une notification comme lue
  Future<bool> markNotificationRead(int notifId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.put(
        Uri.parse('$baseUrl/notifications/$notifId/read'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Marque une notification comme non lue
  Future<bool> markNotificationUnread(int notifId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.put(
        Uri.parse('$baseUrl/notifications/$notifId/unread'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Marque toutes les notifications comme lues
  Future<bool> markAllNotificationsRead() async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Met à jour l'avatar de l'utilisateur connecté
  Future<Map<String, dynamic>> updateAvatar(String avatarUrl) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.put(
        Uri.parse('$baseUrl/users/me/avatar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'avatar_url': avatarUrl}),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'avatar_url': data['avatar_url']};
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      developer.log('Update avatar error: $e', name: 'AuthService');
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  /// Upload une image depuis un XFile (compatible Web + Mobile)
  Future<String?> uploadImageFromXFile(dynamic xFile) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Read bytes from XFile (works on both Web and Mobile)
      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name ?? 'image.jpg';
      
      // Detect MIME type from extension
      final ext = fileName.split('.').last.toLowerCase();
      final mimeTypes = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'gif': 'image/gif', 'webp': 'image/webp'};
      final contentType = mimeTypes[ext] ?? 'image/jpeg';

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ));

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final respStr = await streamedResponse.stream.bytesToString();
        final data = json.decode(respStr);
        String? url = data['url'] ?? data['image_url'];
        if (url != null && url.startsWith('/')) {
          url = '$baseUrl$url';
        }
        developer.log('Image uploaded successfully: $url', name: 'AuthService');
        return url;
      }
      developer.log('Upload failed: ${streamedResponse.statusCode}', name: 'AuthService');
      return null;
    } catch (e) {
      developer.log('Upload image error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Upload une image par chemin (Mobile uniquement, fallback)
  Future<String?> uploadImage(String filePath) async {
    try {
      final token = await _getToken();
      if (token == null) return null;
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final respStr = await streamedResponse.stream.bytesToString();
        final data = json.decode(respStr);
        String? url = data['url'] ?? data['image_url'];
        if (url != null && url.startsWith('/')) {
          url = '$baseUrl$url';
        }
        return url;
      }
      developer.log('Upload failed: ${streamedResponse.statusCode}', name: 'AuthService');
      return null;
    } catch (e) {
      developer.log('Upload image error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Cree une nouvelle publication
  Future<Map<String, dynamic>> createPost({
    required String userName,
    required String userAvatarUrl,
    required String imageUrl,
    required String description,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_name': userName,
          'user_avatar_url': userAvatarUrl,
          'image_url': imageUrl,
          'description': description,
        }),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Cas spécial : IA a signalé le contenu → envoyé en attente admin
        if (data['ai_flagged'] == true) {
          return {
            'success': true,
            'ai_flagged': true,
            'status': 'pending_review',
            'rejection_category': data['rejection_category'] ?? 'offtopic',
            'rejection_title':    data['rejection_title']    ?? 'Publication signalée',
            'rejection_body':     data['rejection_body']     ?? 'Votre publication a été transmise à un administrateur.',
            'rejection_tip':      data['rejection_tip']      ?? 'Publiez du contenu lié à l\'écologie.',
            'data': data,
          };
        }

        return {
          'success': true,
          'data': data,
          'status': data['status'] ?? 'published', // published | pending_review
        };
      }

      return {'success': false, 'message': 'Erreur lors de la création de la publication'};

    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Met a jour une publication
  Future<bool> updatePost(String postId, String description) async {
    try {
      final token = await _getToken();
      final response = await _http.put(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'description': description}),
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Supprime une publication
  Future<bool> deletePost(String postId) async {
    try {
      final token = await _getToken();
      final response = await _http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        await CacheService.invalidate(CacheService.kFeedPosts);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Bascule l'etat de like d'une publication
  Future<Map<String, dynamic>> toggleLikePost(String postId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        data['success'] = true;
        // Invalider le cache du feed pour que le prochain chargement soit frais
        await CacheService.invalidate(CacheService.kFeedPosts);
        return data;
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Bascule l'etat d'enregistrement d'une publication sur le serveur
  Future<Map<String, dynamic>> toggleSavePost(String postId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _http.post(
        Uri.parse('$baseUrl/posts/$postId/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        data['success'] = true;
        // Invalider le cache du feed pour que le prochain chargement soit frais
        await CacheService.invalidate(CacheService.kFeedPosts);
        return data;
      }
      debugPrint('[SavePost] Échec: status=${response.statusCode}, body=${response.body}');
      return {'success': false, 'message': 'Erreur (${response.statusCode})'};
    } catch (e) {
      debugPrint('[SavePost] Exception: $e');
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Ajoute un commentaire (ou une réponse) a une publication
  Future<Map<String, dynamic>> addComment(String postId, String userName, String? userAvatarUrl, String content, {int? parentId}) async {
    try {
      final token = await _getToken();

      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final body = <String, dynamic>{
        'user_name': userName,
        'user_avatar_url': userAvatarUrl,
        'content': content,
      };
      if (parentId != null) body['parent_id'] = parentId;

      final response = await _http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        // Invalider le cache du feed pour que le prochain chargement soit frais
        await CacheService.invalidate(CacheService.kFeedPosts);
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
      return {'success': false, 'message': 'Erreur serveur lors de l\'ajout du commentaire'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Modifie un commentaire
  Future<Map<String, dynamic>> updateComment(int commentId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _http.put(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
      return {'success': false, 'message': 'Erreur lors de la modification du commentaire'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Supprime un commentaire
  Future<bool> deleteComment(int commentId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await _http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Recupere les publications enregistrees depuis le serveur
  Future<List<dynamic>?> fetchSavedPosts() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await _http.get(
        Uri.parse('$baseUrl/users/me/saved-posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Récupère la liste des utilisateurs ayant aimé une publication
  Future<List<Map<String, dynamic>>> fetchPostLikers(String postId) async {
    try {
      final response = await _http.get(
        Uri.parse('$baseUrl/posts/$postId/likers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère une publication unique par son ID (endpoint dédié, performant)
  Future<Map<String, dynamic>?> fetchSinglePost(int postId) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await _http.get(
        Uri.parse('$baseUrl/posts/$postId/detail'),
        headers: headers,
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère les statistiques globales de la plateforme
  Future<Map<String, dynamic>> fetchPlatformStats() async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/stats')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Récupère le conseil écologique du jour
  Future<Map<String, dynamic>> fetchDailyTip() async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/tips/daily')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Recupere les statistiques personnelles de l'utilisateur connecte
  Future<Map<String, dynamic>> fetchMyStats() async {
    try {
      final token = await _getToken();
      if (token == null) return {};
      final response = await _http.get(
        Uri.parse('$baseUrl/users/me/stats'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      developer.log('Erreur fetchMyStats: $e', name: 'AuthService');
      return {};
    }
  }

  /// Récupère le profil utilisateur actuel depuis /users/me (inclut global_score)
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return null;
      final response = await _http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      developer.log('Erreur fetchUserProfile: $e', name: 'AuthService');
      return null;
    }
  }

  /// Récupère l'historique des points gagnés par l'utilisateur connecté depuis /users/me/points-history
  Future<List<dynamic>> fetchPointsHistory() async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final response = await _http.get(
        Uri.parse('$baseUrl/users/me/points-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      developer.log('Erreur fetchPointsHistory: $e', name: 'AuthService');
      return [];
    }
  }

  /// Récupère l'impact écologique personnel depuis /users/me/impact
  /// Retourne scan_count, quiz_count, co2_saved_kg, waste_sorted_kg,
  /// trees_equivalent, waste_by_type, total_scan_points, total_quiz_points,
  /// posts_count, likes_received.
  Future<Map<String, dynamic>> fetchMyImpact() async {
    try {
      final token = await _getToken();
      if (token == null) return {};
      final response = await _http.get(
        Uri.parse('$baseUrl/users/me/impact'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(
            json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      developer.log('Erreur fetchMyImpact: $e', name: 'AuthService');
      return {};
    }
  }


  // ===========================================
  // ADMINISTRATION DES UTILISATEURS
  // ===========================================

  /// Liste tous les utilisateurs
  Future<List<dynamic>> getAllUsers() async {
    try {
      final token = await _getToken();
      final response = await _http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Erreur de chargement des utilisateurs');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cree un nouvel utilisateur (Admin seulement)
  Future<Map<String, dynamic>> createUserAdmin({
    required String email,
    required String fullName,
    required String password,
    required String role,
  }) async {
    try {
      final token = await _getToken();
      final response = await _http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
          'full_name': fullName,
          'password': password,
          'role': role,
        }),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': error['detail'] ?? 'Erreur de création'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Modifie un utilisateur (Admin seulement)
  Future<Map<String, dynamic>> updateUserAdmin({
    required int userId,
    String? fullName,
    String? role,
    String? password,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (role != null) data['role'] = role;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await _http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      } else {
        return {'success': false, 'message': 'Erreur de modification'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Supprime un utilisateur
  Future<bool> deleteUserAdmin(int userId) async {
    try {
      final token = await _getToken();
      final response = await _http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Deconnexion complète (JWT + Google + Facebook)
  Future<void> logout() async {
    // ── Désenregistrer le token FCM côté backend avant d'effacer les identifiants localement ──
    try {
      final token = await _getToken();
      if (token != null) {
        await _http.put(
          Uri.parse('$baseUrl/notifications/fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'token': ''}),
        ).timeout(const Duration(seconds: 3)).timeout(_kTimeout);
        developer.log('[FCM] Token FCM désenregistré avec succès sur le backend', name: 'AuthService');
      }
    } catch (e) {
      developer.log('[FCM] Impossible de désenregistrer le token FCM : $e', name: 'AuthService');
    }

    // ── Vider le cache local des notifications en-app ──
    try {
      NotificationService().clear();
      developer.log('[FCM] Cache local des notifications vidé', name: 'AuthService');
    } catch (e) {
      developer.log('[FCM] Erreur lors du vidage des notifications : $e', name: 'AuthService');
    }

    await clearTokens();
    // Déconnexion Google
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    // Déconnexion Facebook
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  /// Récupère les points de collecte depuis l'API
  /// Endpoint public — aucun token nécessaire, aucun risque de déconnexion.
  Future<List<Map<String, dynamic>>> fetchCollectionPoints({String? type, String? search}) async {
    try {
      final params = <String, String>{};
      if (type != null) params['type'] = type;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse('$baseUrl/collection-points')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      // Appel sans Authorization : /collection-points est public
      // → jamais de 401, jamais de risque de déconnexion
      final response = await _http.get(uri).timeout(const Duration(seconds: 10)).timeout(_kTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      developer.log('Erreur fetch collection points: $e', name: 'AuthService');
      return [];
    }
  }

  // ===========================================
  // TESTIMONIALS (Avis citoyens)
  // ===========================================

  /// Récupère tous les témoignages
  Future<List<Map<String, dynamic>>> fetchTestimonials() async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/testimonials')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      developer.log('Erreur fetch testimonials: $e', name: 'AuthService');
      return [];
    }
  }

  /// Ajouter un avis
  Future<Map<String, dynamic>> createTestimonial(String content, int rating) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.post(
        Uri.parse('$baseUrl/testimonials'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content, 'rating': rating}),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
      final error = json.decode(utf8.decode(response.bodyBytes));
      return {'success': false, 'message': error['detail'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  /// Supprimer un avis
  Future<bool> deleteTestimonial(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.delete(
        Uri.parse('$baseUrl/testimonials/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================
  // CENTER PROPOSALS (Propositions de centres)
  // ===========================================

  /// Récupère les propositions de centres (admin uniquement)
  Future<List<Map<String, dynamic>>> fetchCenterProposals({String? status}) async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      final uri = Uri.parse('$baseUrl/center-proposals').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );
      final response = await _http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      developer.log('Erreur fetch center proposals: $e', name: 'AuthService');
      return [];
    }
  }

  /// Proposer un nouveau centre de tri
  Future<Map<String, dynamic>> createCenterProposal({
    required String name,
    required String address,
    String? lat,
    String? lng,
    String wasteTypes = '',
    String? description,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.post(
        Uri.parse('$baseUrl/center-proposals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'address': address,
          'lat': lat,
          'lng': lng,
          'waste_types': wasteTypes,
          'description': description,
        }),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
      final error = json.decode(utf8.decode(response.bodyBytes));
      return {'success': false, 'message': error['detail'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  /// Supprimer une proposition
  Future<bool> deleteCenterProposal(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.delete(
        Uri.parse('$baseUrl/center-proposals/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Met à jour le statut d'une proposition (admin: approved/rejected/pending)
  Future<bool> updateCenterProposalStatus(int id, String status) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.put(
        Uri.parse('$baseUrl/center-proposals/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================
  // MODÉRATION DES PUBLICATIONS (Admin)
  // ===========================================

  /// Récupère les publications en attente de validation
  Future<Map<String, dynamic>> fetchPendingPosts({int skip = 0, int limit = 50}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'total': 0, 'posts': []};
      final response = await _http.get(
        Uri.parse('$baseUrl/admin/moderation/pending?skip=$skip&limit=$limit'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {'total': 0, 'posts': []};
    } catch (e) {
      developer.log('Erreur fetch pending posts: $e', name: 'AuthService');
      return {'total': 0, 'posts': []};
    }
  }

  /// Récupère les statistiques de modération (admin)
  Future<Map<String, dynamic>> fetchModerationStats() async {
    try {
      final token = await _getToken();
      if (token == null) return {};
      final response = await _http.get(
        Uri.parse('$baseUrl/admin/moderation/stats'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Approuve une publication en attente
  Future<bool> approvePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await _http.put(
        Uri.parse('$baseUrl/admin/moderation/$postId/approve'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Rejette une publication
  Future<bool> rejectPost(int postId, {String? reason}) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final uri = reason != null
          ? Uri.parse('$baseUrl/admin/moderation/$postId/reject?reason=${Uri.encodeComponent(reason)}')
          : Uri.parse('$baseUrl/admin/moderation/$postId/reject');
      final response = await _http.put(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Récupère les statistiques admin consolidées (users, posts, points)
  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final token = await _getToken();
      // Fetch platform stats (public) + moderation stats (admin) in parallel
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/stats')),
        http.get(
          Uri.parse('$baseUrl/admin/moderation/stats'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('$baseUrl/users?limit=1'),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      final platformData = results[0].statusCode == 200
          ? Map<String, dynamic>.from(json.decode(utf8.decode(results[0].bodyBytes)))
          : <String, dynamic>{};
      final moderationData = results[1].statusCode == 200
          ? Map<String, dynamic>.from(json.decode(utf8.decode(results[1].bodyBytes)))
          : <String, dynamic>{};

      return {
        ...platformData,
        'total_users': platformData['total_users'] ?? 0,
        'total_posts': platformData['total_posts'] ?? 0,
        'total_collection_points': platformData['total_collection_points'] ?? 0,
        'pending_review': moderationData['pending_review'] ?? 0,
        'pending_testimonials': platformData['pending_testimonials'] ?? 0,
        'total_testimonials': platformData['total_testimonials'] ?? 0,
        'co2_saved_kg': platformData['co2_saved_kg'] ?? 0,
        'waste_sorted_kg': platformData['waste_sorted_kg'] ?? 0,
        'trees_equivalent': platformData['trees_equivalent'] ?? 0,
      };
    } catch (e) {
      developer.log('Erreur fetchAdminStats: $e', name: 'AuthService');
      return {};
    }
  }

  // ===========================================
  // QUIZ AUTOMATIQUE (Gemini AI)
  // ===========================================

  /// Upload un PDF de quiz → Gemini extrait les questions et le corrigé
  Future<Map<String, dynamic>> createQuizFromPdf(dynamic xFile, {String? title, String? description}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};

      final uri = Uri.parse('$baseUrl/quiz/create');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name ?? 'quiz.pdf';

      request.files.add(http.MultipartFile.fromBytes(
        'file', bytes, filename: fileName,
        contentType: MediaType.parse('application/pdf'),
      ));

      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;

      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();
      final data = json.decode(respStr);

      if (streamedResponse.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      developer.log('createQuizFromPdf error: $e', name: 'AuthService');
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Re-tenter l'extraction Gemini pour un quiz en erreur
  Future<Map<String, dynamic>> retryQuiz(int quizId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.post(
        Uri.parse('$baseUrl/quiz/$quizId/retry'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Supprime un quiz (éducateur créateur ou admin)
  Future<Map<String, dynamic>> deleteQuiz(int quizId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.delete(
        Uri.parse('$baseUrl/quiz/$quizId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Liste les quiz de l'éducateur connecté
  Future<List<dynamic>> fetchMyQuizzes() async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final response = await _http.get(
        Uri.parse('$baseUrl/quiz/my-quizzes'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['quizzes'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les résultats d'un quiz (éducateur)
  Future<Map<String, dynamic>> fetchQuizResults(int quizId) async {
    try {
      final token = await _getToken();
      if (token == null) return {};
      final response = await _http.get(
        Uri.parse('$baseUrl/quiz/$quizId/results'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Soumet les réponses d'un étudiant à un quiz
  Future<Map<String, dynamic>> submitQuizAnswers(int quizId, Map<String, String> answers) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.post(
        Uri.parse('$baseUrl/quiz/$quizId/submit'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(answers),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Liste tous les quiz disponibles (public, pas besoin de token)
  Future<List<dynamic>> fetchAvailableQuizzes() async {
    try {
      final response = await _http.get(
        Uri.parse('$baseUrl/quiz/available'),
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['quizzes'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère un quiz par son ID (avec token pour masquer/afficher les réponses)
  Future<Map<String, dynamic>?> fetchQuizById(int quizId) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await _http.get(
        Uri.parse('$baseUrl/quiz/$quizId'),
        headers: headers,
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère le résultat personnel de l'utilisateur pour un quiz donné (null = pas encore fait)
  Future<Map<String, dynamic>?> fetchMyQuizResult(int quizId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;
      final response = await _http.get(
        Uri.parse('$baseUrl/quiz/$quizId/my-result'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null; // 404 = pas encore soumis
    } catch (e) {
      return null;
    }
  }

  // ===========================================
  // VIDÉOS ÉDUCATEUR + CATÉGORIES
  // ===========================================

  /// Crée une catégorie avec image de couverture
  Future<Map<String, dynamic>> createVideoCategory({
    required String title,
    String? description,
    dynamic coverImage,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final uri = Uri.parse('$baseUrl/educator-videos/categories');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title;
      if (description != null && description.isNotEmpty) request.fields['description'] = description;
      if (coverImage != null) {
        final bytes = await coverImage.readAsBytes();
        final name = coverImage.name ?? 'cover.jpg';
        request.files.add(http.MultipartFile.fromBytes('cover_image', bytes, filename: name, contentType: MediaType.parse('image/jpeg')));
      }
      final resp = await request.send();
      final data = json.decode(await resp.stream.bytesToString());
      if (resp.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'message': data['detail'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Liste toutes les catégories (public)
  Future<List<dynamic>> fetchVideoCategories() async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/educator-videos/categories')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['categories'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Détail d'une catégorie avec ses vidéos
  Future<Map<String, dynamic>?> fetchCategoryDetail(int catId) async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/educator-videos/categories/$catId')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteVideoCategory(int catId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final resp = await _http.delete(Uri.parse('$baseUrl/educator-videos/categories/$catId'), headers: {'Authorization': 'Bearer $token'}).timeout(_kTimeout);
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Upload une vidéo dans une catégorie
  Future<Map<String, dynamic>> uploadEducatorVideo({
    required dynamic videoFile,
    required String title,
    String? description,
    String? duration,
    int? categoryId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final uri = Uri.parse('$baseUrl/educator-videos/upload');
      final request = http.MultipartRequest('POST', uri)..headers['Authorization'] = 'Bearer $token';
      final bytes = await videoFile.readAsBytes();
      final fileName = videoFile.name ?? 'video.mp4';
      final ext = fileName.split('.').last.toLowerCase();
      final mimeMap = {'mp4': 'video/mp4', 'webm': 'video/webm', 'mov': 'video/quicktime', 'avi': 'video/x-msvideo', 'mkv': 'video/x-matroska'};
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName, contentType: MediaType.parse(mimeMap[ext] ?? 'video/mp4')));
      request.fields['title'] = title;
      if (description != null && description.isNotEmpty) request.fields['description'] = description;
      if (duration != null && duration.isNotEmpty) request.fields['duration'] = duration;
      if (categoryId != null) request.fields['category_id'] = categoryId.toString();
      final resp = await request.send();
      final data = json.decode(await resp.stream.bytesToString());
      if (resp.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      developer.log('uploadEducatorVideo error: $e', name: 'AuthService');
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  /// Liste toutes les vidéos (public)
  Future<List<dynamic>> fetchEducatorVideos() async {
    try {
      final response = await _http.get(Uri.parse('$baseUrl/educator-videos/')).timeout(_kTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['videos'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Liste mes vidéos
  Future<List<dynamic>> fetchMyEducatorVideos() async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final resp = await _http.get(Uri.parse('$baseUrl/educator-videos/my-videos'), headers: {'Authorization': 'Bearer $token'}).timeout(_kTimeout);
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes));
        return data['videos'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Supprime une vidéo
  Future<bool> deleteEducatorVideo(int videoId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final resp = await _http.delete(Uri.parse('$baseUrl/educator-videos/$videoId'), headers: {'Authorization': 'Bearer $token'}).timeout(_kTimeout);
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================
  // PROFIL UTILISATEUR
  // ===========================================

  /// Met à jour le nom complet de l'utilisateur connecté
  Future<Map<String, dynamic>> updateProfile({required String fullName}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non connecté'};
      final response = await _http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'full_name': fullName}),
      ).timeout(_kTimeout);
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, 'full_name': data['full_name']};
      }
      return {'success': false, 'message': data['detail'] ?? 'Erreur serveur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }
}

