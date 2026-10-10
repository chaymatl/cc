/// lib/core/api/api_client.dart
///
/// Client HTTP centralisé — point d'entrée unique vers FastAPI.
///
/// Responsabilités :
///   • Attacher automatiquement le Bearer token JWT
///   • Rafraîchir le token (401 → refresh → retry)
///   • Décoder UTF-8 de façon uniforme
///   • Gérer les erreurs réseau
///
/// Règle : TOUS les services feature-based passent par ApiClient.
/// Personne n'instancie http.Client directement sauf ici.
library api_client;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants.dart';
import '../../models/user_model.dart'; // AuthState


/// Réponse normalisée retournée par ApiClient.
class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final bool isSuccess;
  final String? error;

  const ApiResponse._({
    required this.statusCode,
    required this.body,
    required this.isSuccess,
    this.error,
  });

  factory ApiResponse.success(int code, Map<String, dynamic> body) =>
      ApiResponse._(statusCode: code, body: body, isSuccess: true);

  factory ApiResponse.failure(int code, String error, [Map<String, dynamic>? body]) =>
      ApiResponse._(statusCode: code, body: body ?? {}, isSuccess: false, error: error);
}

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  final http.Client _http = http.Client();
  static const Duration _timeout = Duration(seconds: 20);

  // ── Secure Token Storage ───────────────────────────────────────────────────
  // ⚠️ Les options Android doivent correspondre exactement à celles utilisées
  // dans AuthService et main.dart (AndroidOptions()) pour accéder au même
  // espace de stockage Keystore. Une instance sans options utiliserait un
  // cipher différent et ne lirait pas les tokens écrits par AuthService.
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(), // AES-256 via Keystore — idem AuthService
  );
  static const String _kToken   = 'jwt_token';
  static const String _kRefresh = 'refresh_token';

  // ── Token Management ──────────────────────────────────────────────────────

  /// Retourne le token JWT : d'abord depuis AuthState (mémoire, sans I/O),
  /// puis fallback vers le SecureStorage. Retourne null si AuthState.authToken
  /// est null (token effacé après refresh raté) même si le SecureStorage
  /// contient encore un token expiré.
  Future<String?> getToken() async {
    // AuthState est la source de vérité en mémoire.
    // Si null → session expirée/déconnectée, ne pas lire le stockage.
    final memToken = AuthState.authToken;
    if (memToken != null) return memToken;
    return null;
  }

  Future<String?> _getRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kToken, value: token);
    AuthState.authToken = token;
  }

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefresh, value: token);

  Future<void> clearTokens() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kRefresh);
    AuthState.authToken = null;
  }

  /// Headers JSON + Bearer token (si disponible).
  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Tente de renouveler le token via /token/refresh.
  Future<bool> _tryRefresh() async {
    final refresh = await _getRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await _http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/token/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token']?.toString();
        if (accessToken == null || accessToken.isEmpty) return false;
        await saveToken(accessToken);
        if (data['refresh_token'] != null) {
          await saveRefreshToken(data['refresh_token'].toString());
        }
        return true;
      }
    } catch (e) {
      developer.log('[ApiClient] Token refresh failed: $e', name: 'ApiClient');
    }
    return false;
  }

  // ── HTTP Verbs ───────────────────────────────────────────────────────────────

  /// GET authentifié avec retry 401.
  Future<ApiResponse> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path')
        .replace(queryParameters: query);
    try {
      final headers = await _headers();
      var response = await _http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 401) {
        if (await _tryRefresh()) {
          final newHeaders = await _headers();
          response = await _http.get(uri, headers: newHeaders).timeout(_timeout);
        }
      }
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// POST JSON.
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      // ignore: prefer_final_locals — headers est muté si !requireAuth
      var headers = await _headers();
      if (!requireAuth) headers.remove('Authorization');
      final response = await _http
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// POST form-urlencoded (login JWT).
  Future<ApiResponse> postForm(String path, Map<String, String> fields) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _http
          .post(uri,
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: fields)
          .timeout(_timeout);
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// PUT JSON.
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final headers = await _headers();
      final response = await _http
          .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// PATCH JSON.
  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final headers = await _headers();
      final response = await _http
          .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// DELETE.
  Future<ApiResponse> delete(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final headers = await _headers(json: false);
      final response = await _http.delete(uri, headers: headers).timeout(_timeout);
      return _parse(response);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau : $e');
    }
  }

  /// Multipart upload (images, PDF, vidéos).
  Future<ApiResponse> upload(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    String contentType = 'application/octet-stream',
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', uri);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        fieldName, bytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ));
      if (fields != null) request.fields.addAll(fields);
      final streamed = await request.send().timeout(_timeout);
      final body = await streamed.stream.bytesToString();
      final parsed = _tryDecode(body);
      return streamed.statusCode >= 200 && streamed.statusCode < 300
          ? ApiResponse.success(streamed.statusCode, parsed)
          : ApiResponse.failure(streamed.statusCode,
              parsed['detail'] as String? ?? 'Erreur upload', parsed);
    } catch (e) {
      return ApiResponse.failure(0, 'Erreur réseau upload : $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  ApiResponse _parse(http.Response response) {
    final body = _tryDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(response.statusCode, body);
    }
    // FastAPI renvoie detail: String en 401/404 mais detail: List<Map> en 422
    final rawDetail = body['detail'];
    final String error;
    if (rawDetail is String) {
      error = rawDetail;
    } else if (rawDetail is List) {
      // 422 Unprocessable Entity — extraire le premier message de validation
      error = rawDetail.isNotEmpty
          ? (rawDetail.first['msg'] ?? 'Validation error').toString()
          : 'Erreur de validation';
    } else {
      error = body['message'] as String? ?? 'Erreur HTTP ${response.statusCode}';
    }
    return ApiResponse.failure(response.statusCode, error, body);
  }

  Map<String, dynamic> _tryDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      // Si c'est une liste, on l'encapsule
      if (decoded is List) return {'items': decoded};
      return {'value': decoded};
    } catch (_) {
      return {'raw': raw};
    }
  }
}
