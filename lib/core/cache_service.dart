// lib/core/cache_service.dart
// Service de cache local avec TTL — mode hors-ligne automatique
// Utilise SharedPreferences (déjà installé) → zéro dépendance supplémentaire
//
// Usage :
//   final posts = await CacheService.getOrFetch(
//     key: 'feed_posts',
//     ttl: const Duration(minutes: 10),
//     fetcher: () => authService.fetchPosts(),
//   );
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Résultat de cache : données + état (fresh / stale / offline)
// ─────────────────────────────────────────────────────────────────────────────

enum CacheStatus { fresh, stale, offline }

class CacheResult<T> {
  final T? data;
  final CacheStatus status;
  final DateTime? cachedAt;

  const CacheResult({this.data, required this.status, this.cachedAt});

  bool get isOffline => status == CacheStatus.offline && data != null;
  bool get hasData => data != null;

  /// Retourne true si les données viennent du cache (pas fraîches du réseau)
  bool get fromCache => status != CacheStatus.fresh;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service principal
// ─────────────────────────────────────────────────────────────────────────────

class CacheService {
  static const String _prefix = 'cache_v1_';
  static const String _tsPrefx = 'cache_ts_';

  // TTL par défaut selon le type de données
  static const Duration kTtlFeed          = Duration(minutes: 5);
  static const Duration kTtlUserProfile   = Duration(minutes: 15);
  static const Duration kTtlLeaderboard   = Duration(minutes: 2);
  static const Duration kTtlCenters       = Duration(minutes: 30);
  static const Duration kTtlEducation     = Duration(minutes: 30);
  static const Duration kTtlNotifications = Duration(minutes: 2);

  /// Clés standardisées
  static const String kFeedPosts       = 'feed_posts';
  static const String kLeaderboard     = 'leaderboard';
  static const String kCenters         = 'collection_centers';
  static const String kMyStats         = 'my_stats';
  static const String kNotifications   = 'notifications';
  static const String kEducationVideos = 'education_videos';
  static const String kQuizList        = 'quiz_list';

  // ── API publique ─────────────────────────────────────────────────────────

  /// Lit le cache puis appelle [fetcher]. Si [fetcher] échoue → renvoie le cache.
  /// [ttl] : durée de validité avant de refetcher
  static Future<CacheResult<T>> getOrFetch<T>({
    required String key,
    required Duration ttl,
    required Future<T?> Function() fetcher,
    T? Function(dynamic json)? deserializer,
  }) async {
    // 1. Lire le cache
    final cached = await _readCache<T>(key, deserializer: deserializer);
    final age    = await _cacheAge(key);

    // 2. Données fraîches en cache → pas besoin de fetcher
    if (cached != null && age != null && age < ttl) {
      developer.log('[Cache] HIT fresh — $key (${age.inSeconds}s)', name: 'CacheService');
      return CacheResult(data: cached, status: CacheStatus.fresh, cachedAt: DateTime.now().subtract(age));
    }

    // 3. Appel réseau
    try {
      final fresh = await fetcher();
      if (fresh != null) {
        await _writeCache(key, fresh);
        developer.log('[Cache] MISS → fetched — $key', name: 'CacheService');
        return CacheResult(data: fresh, status: CacheStatus.fresh, cachedAt: DateTime.now());
      }
      // Fetcher a répondu null → fallback cache
      if (cached != null) {
        developer.log('[Cache] NULL response → fallback stale — $key', name: 'CacheService');
        return CacheResult(data: cached, status: CacheStatus.stale);
      }
      return const CacheResult(status: CacheStatus.offline);
    } catch (e) {
      // Erreur réseau → fallback cache
      developer.log('[Cache] OFFLINE → fallback — $key ($e)', name: 'CacheService');
      if (cached != null) {
        return CacheResult(data: cached, status: CacheStatus.offline,
            cachedAt: age != null ? DateTime.now().subtract(age) : null);
      }
      return const CacheResult(status: CacheStatus.offline);
    }
  }

  /// Lit directement depuis le cache (sans fetcher).
  static Future<T?> read<T>(String key, {T? Function(dynamic json)? deserializer}) =>
      _readCache<T>(key, deserializer: deserializer);

  /// Écrit manuellement dans le cache (ex : après un POST réussi).
  static Future<void> write(String key, dynamic data) => _writeCache(key, data);

  /// Invalide une clé (force un re-fetch au prochain appel).
  static Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_tsPrefx$key');
    developer.log('[Cache] INVALIDATED — $key', name: 'CacheService');
  }

  /// Vide tout le cache de l'application.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // .toList() pour éviter la modification concurrente pendant l'itération
    final keys = prefs.getKeys()
        .where((k) => k.startsWith(_prefix) || k.startsWith(_tsPrefx))
        .toList();
    for (final k in keys) { await prefs.remove(k); }
    developer.log('[Cache] CLEARED all (${keys.length} entries)', name: 'CacheService');
  }

  /// Retourne l'âge du cache pour une clé.
  static Future<Duration?> _cacheAge(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final tsStr = prefs.getString('$_tsPrefx$key');
    if (tsStr == null) return null;
    final ts = DateTime.tryParse(tsStr);
    if (ts == null) return null;
    return DateTime.now().difference(ts);
  }

  // ── Sérialisation interne ────────────────────────────────────────────────

  static Future<void> _writeCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(data);
      await prefs.setString('$_prefix$key', encoded);
      await prefs.setString('$_tsPrefx$key', DateTime.now().toIso8601String());
    } catch (e) {
      developer.log('[Cache] WRITE error — $key: $e', name: 'CacheService');
    }
  }

  static Future<T?> _readCache<T>(String key, {T? Function(dynamic json)? deserializer}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (deserializer != null) return deserializer(decoded);
      // Cast sécurisé : jsonDecode retourne dynamic (List/Map/String/num)
      // Si T == List<dynamic>, le cast direct fonctionne
      // Si T est un type typé personnalisé, utiliser un deserializer
      if (decoded is T) return decoded;
      developer.log('[Cache] Type mismatch for $key: got ${decoded.runtimeType}, expected $T', name: 'CacheService');
      return null;
    } catch (e) {
      developer.log('[Cache] READ error — $key: $e', name: 'CacheService');
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget : bandeau 'Mode hors-ligne' à afficher en tête d'écran
// Usage : if (result.isOffline) const OfflineBanner()
// ─────────────────────────────────────────────────────────────────────────────

class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  const OfflineBanner({super.key, this.cachedAt});

  String _formatAge() {
    if (cachedAt == null) return 'données mises en cache';
    final diff = DateTime.now().difference(cachedAt!);
    if (diff.inMinutes < 1) return 'mis à jour à l\'instant';
    if (diff.inMinutes < 60) return 'mis à jour il y a ${diff.inMinutes} min';
    return 'mis à jour il y a ${diff.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade200.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade400.withOpacity(0.7)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Mode hors-ligne · ${_formatAge()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ),
      ]),
    );
  }
}
