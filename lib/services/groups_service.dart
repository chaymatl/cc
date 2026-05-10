// lib/services/groups_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user_model.dart';

class GroupsService {
  static String get _base => ApiConstants.baseUrl;

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (AuthState.authToken != null)
          'Authorization': 'Bearer ${AuthState.authToken}',
      };

  // ── Citoyens ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> searchCitizens({String q = ''}) async {
    try {
      final url = q.isEmpty
          ? '$_base/citizens'
          : '$_base/citizens?q=${Uri.encodeComponent(q)}';
      final res = await http.get(Uri.parse(url), headers: _headers());
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  // ── Groupes ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getMyGroups() async {
    try {
      final res = await http.get(
          Uri.parse('$_base/groups/my'), headers: _headers());
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> createGroup({
    required String name,
    String description = '',
    String color = '#00C896',
  }) async {
    final res = await http.post(
      Uri.parse('$_base/groups'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'description': description,
        'color': color,
      }),
    );
    final data = jsonDecode(res.body);
    return res.statusCode == 201
        ? {'success': true, 'group': data}
        : {'success': false, 'error': data['detail'] ?? 'Erreur'};
  }

  static Future<bool> updateGroup(
      int id, String name, String description, String color) async {
    final res = await http.put(
      Uri.parse('$_base/groups/$id'),
      headers: _headers(),
      body: jsonEncode(
          {'name': name, 'description': description, 'color': color}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteGroup(int id) async {
    final res =
        await http.delete(Uri.parse('$_base/groups/$id'), headers: _headers());
    return res.statusCode == 200;
  }

  static Future<bool> addMember(int groupId, int userId) async {
    final res = await http.post(
      Uri.parse('$_base/groups/$groupId/members'),
      headers: _headers(),
      body: jsonEncode({'user_id': userId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> removeMember(int groupId, int userId) async {
    final res = await http.delete(
        Uri.parse('$_base/groups/$groupId/members/$userId'),
        headers: _headers());
    return res.statusCode == 200;
  }
}
