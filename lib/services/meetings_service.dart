// lib/services/meetings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user_model.dart';

class MeetingsService {
  static String get _base => ApiConstants.baseUrl;

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (AuthState.authToken != null)
          'Authorization': 'Bearer ${AuthState.authToken}',
      };

  // ── Éducateur ──────────────────────────────────────────────────────────────

  /// Créer une séance
  static Future<Map<String, dynamic>> createMeeting({
    required String title,
    required String description,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String audience,
    String groupName = '',
    List<int> citizenIds = const [],
    int? groupId,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/meetings'),
      headers: _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        'audience': audience,
        'group_name': groupName,
        'citizen_ids': citizenIds,
        if (groupId != null) 'group_id': groupId,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) return {'success': true, 'meeting': data};
    return {'success': false, 'error': data['detail'] ?? 'Erreur'};
  }

  /// Liste des séances de l'éducateur
  static Future<List<dynamic>> getMyMeetings() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/meetings/my'),
        headers: _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  /// Modifier une séance
  static Future<bool> updateMeeting(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/meetings/$id'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  /// Supprimer une séance
  static Future<bool> deleteMeeting(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/meetings/$id'),
      headers: _headers(),
    );
    return res.statusCode == 200;
  }

  // ── Citoyen ────────────────────────────────────────────────────────────────

  /// Séances à venir pour le citoyen
  static Future<List<dynamic>> getUpcomingMeetings() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/meetings/upcoming'),
        headers: _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  /// Confirmer ou décliner une invitation
  static Future<bool> respondToMeeting(int meetingId, String status) async {
    final res = await http.post(
      Uri.parse('$_base/meetings/$meetingId/respond'),
      headers: _headers(),
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }
}
