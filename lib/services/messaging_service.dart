// lib/services/messaging_service.dart
// Service Flutter pour la messagerie inter-rôles EcoRewind

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

import '../models/user_model.dart';

class MessagingService {
  static final String _base = ApiConstants.baseUrl;

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers() async {
    final jwt = AuthState.authToken;
    return {
      'Content-Type': 'application/json',
      if (jwt != null && jwt.isNotEmpty) 'Authorization': 'Bearer $jwt',
    };
  }

  /// Vrai seulement si un token JWT valide est en mémoire.
  static bool get _hasValidToken => AuthState.hasValidToken;

  static Map<String, dynamic> _decode(http.Response r) {
    return json.decode(utf8.decode(r.bodyBytes));
  }

  static List<dynamic> _decodeList(http.Response r) {
    return json.decode(utf8.decode(r.bodyBytes)) as List;
  }

  // ── Destinataires éligibles ────────────────────────────────────────────────

  /// Retourne la liste des utilisateurs à qui on peut écrire (filtrée par rôle)
  static Future<List<Map<String, dynamic>>> getEligibleRecipients() async {
    if (!_hasValidToken) return [];
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse('$_base/messages/eligible-recipients'),
        headers: h,
      );
      if (r.statusCode == 200) {
        return _decodeList(r).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // ── Groupes accessibles ───────────────────────────────────────────────────

  /// Groupes de citoyens (éducateur) ou vide pour les autres
  static Future<List<Map<String, dynamic>>> getAccessibleGroups() async {
    if (!_hasValidToken) return [];
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse('$_base/messages/groups'),
        headers: h,
      );
      if (r.statusCode == 200) {
        return _decodeList(r).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // ── Envoyer un message 1-à-1 ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> sendMessage({
    required int receiverId,
    required String content,
    int? parentId,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.post(
        Uri.parse('$_base/messages'),
        headers: h,
        body: json.encode({
          'receiver_id': receiverId,
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        }),
      );
      if (r.statusCode == 201) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Envoyer à un groupe de citoyens ──────────────────────────────────────

  static Future<Map<String, dynamic>?> sendGroupMessage({
    required int groupId,
    required String content,
    int? parentId,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.post(
        Uri.parse('$_base/messages/group'),
        headers: h,
        body: json.encode({
          'group_id': groupId,
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        }),
      );
      if (r.statusCode == 201) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Broadcast collecteurs ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> broadcastToCollectors({
    required List<int> receiverIds,
    required String content,
    String? collectorGroupLabel,
    int? parentId,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.post(
        Uri.parse('$_base/messages/broadcast'),
        headers: h,
        body: json.encode({
          'receiver_ids': receiverIds,
          'content': content,
          if (collectorGroupLabel != null)
            'collector_group_label': collectorGroupLabel,
          if (parentId != null) 'parent_id': parentId,
        }),
      );
      if (r.statusCode == 201) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getConversations() async {
    if (!_hasValidToken) return [];
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse('$_base/messages/conversations'),
        headers: h,
      );
      if (r.statusCode == 200) {
        return _decodeList(r).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // ── Messages d'une conversation 1-à-1 ────────────────────────────────────

  static Future<Map<String, dynamic>?> getConversation(
    int userId, {
    int skip = 0,
    int limit = 50,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse('$_base/messages/conversation/$userId?skip=$skip&limit=$limit'),
        headers: h,
      );
      if (r.statusCode == 200) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Messages d'un groupe de citoyens ─────────────────────────────────────

  static Future<Map<String, dynamic>?> getGroupConversation(
    int groupId, {
    int skip = 0,
    int limit = 50,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse(
            '$_base/messages/group-conversation/$groupId?skip=$skip&limit=$limit'),
        headers: h,
      );
      if (r.statusCode == 200) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Répondre ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> replyToMessage({
    required int messageId,
    required String content,
  }) async {
    if (!_hasValidToken) return null;
    try {
      final h = await _headers();
      final r = await http.post(
        Uri.parse('$_base/messages/$messageId/reply'),
        headers: h,
        body: json.encode({'content': content}),
      );
      if (r.statusCode == 201) return _decode(r);
    } catch (_) {}
    return null;
  }

  // ── Marquer comme lu ─────────────────────────────────────────────────────

  static Future<void> markAsRead(int messageId) async {
    if (!_hasValidToken) return;
    try {
      final h = await _headers();
      await http.put(
        Uri.parse('$_base/messages/$messageId/read'),
        headers: h,
      );
    } catch (_) {}
  }

  /// Marque TOUS les messages d'une conversation comme lus en un seul appel.
  /// À appeler dès l'ouverture de la conversation pour déclencher les coches bleues.
  static Future<void> markConversationAsRead(int partnerId) async {
    if (!_hasValidToken) return;
    try {
      final h = await _headers();
      await http.post(
        Uri.parse('$_base/messages/conversation/$partnerId/read-all'),
        headers: h,
      );
    } catch (_) {}
  }

  /// Marque TOUS les messages d'un groupe comme lus en un seul appel.
  /// À appeler dès l'ouverture du chat de groupe pour déclencher les coches bleues.
  static Future<void> markGroupAsRead(int groupId) async {
    try {
      final h = await _headers();
      await http.post(
        Uri.parse('$_base/messages/group/$groupId/read-all'),
        headers: h,
      );
    } catch (_) {
      // Silencieux — non critique si l'endpoint n'existe pas encore
    }
  }


  // ── Compteur non lus ─────────────────────────────────────────────────────

  static Future<int> getUnreadCount() async {
    if (!_hasValidToken) return 0;
    try {
      final h = await _headers();
      final r = await http.get(
        Uri.parse('$_base/messages/unread-count'),
        headers: h,
      );
      if (r.statusCode == 200) {
        return _decode(r)['count'] as int? ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}
