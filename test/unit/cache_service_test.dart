// test/unit/cache_service_test.dart
// Tests unitaires pour CacheService
// Lancer avec : flutter test test/unit/cache_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_rewind/core/cache_service.dart';

void main() {
  // Initialiser SharedPreferences avec des valeurs mock avant chaque test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CacheService — getOrFetch', () {
    test('retourne les données fraîches quand le fetcher réussit', () async {
      final result = await CacheService.getOrFetch<List<dynamic>>(
        key: 'test_fresh',
        ttl: const Duration(minutes: 5),
        fetcher: () async => [1, 2, 3],
      );

      expect(result.hasData, isTrue);
      expect(result.data, equals([1, 2, 3]));
      expect(result.status, equals(CacheStatus.fresh));
      expect(result.isOffline, isFalse);
    });

    test('retourne le cache quand le fetcher lève une exception (mode offline)',
        () async {
      // 1. Pré-remplir le cache
      await CacheService.write('test_offline', ['post1', 'post2']);

      // 2. TTL = Duration.zero → le cache est immédiatement expiré → fetcher appelé
      //    Le fetcher échoue → fallback sur le cache expiré (status = offline)
      final result = await CacheService.getOrFetch<List<dynamic>>(
        key: 'test_offline',
        ttl: Duration.zero,  // Force expiration immédiate
        fetcher: () async => throw Exception('Pas de réseau'),
      );

      expect(result.hasData, isTrue);
      expect(result.data, equals(['post1', 'post2']));
      expect(result.status, equals(CacheStatus.offline));
      expect(result.isOffline, isTrue);
    });

    test('retourne CacheStatus.offline sans données si cache vide et réseau KO',
        () async {
      final result = await CacheService.getOrFetch<List<dynamic>>(
        key: 'test_empty_offline',
        ttl: const Duration(minutes: 5),
        fetcher: () async => throw Exception('Réseau indisponible'),
      );

      expect(result.hasData, isFalse);
      expect(result.status, equals(CacheStatus.offline));
    });

    test('ne re-fetche pas si les données sont fraîches (dans le TTL)', () async {
      int fetchCount = 0;
      const testKey = 'test_ttl_unique_${1}';

      // Premier appel — fetche depuis le réseau
      final first = await CacheService.getOrFetch<String>(
        key: testKey,
        ttl: const Duration(minutes: 10),
        fetcher: () async {
          fetchCount++;
          return 'données_v1';
        },
      );
      expect(first.status, equals(CacheStatus.fresh)); // Réseau → fresh
      expect(fetchCount, equals(1));

      // Deuxième appel immédiat — doit utiliser le cache (TTL non expiré)
      final second = await CacheService.getOrFetch<String>(
        key: testKey,
        ttl: const Duration(minutes: 10),
        fetcher: () async {
          fetchCount++;
          return 'données_v2';
        },
      );

      // Le cache est valide → fresh depuis le cache, fetcher PAS rappelé
      expect(second.status, equals(CacheStatus.fresh));
      expect(second.data, equals('données_v1')); // Données du cache, pas v2
      expect(fetchCount, equals(1)); // Fetcher appelé une seule fois
    });
  });

  group('CacheService — invalidate & clearAll', () {
    test('invalidate force un re-fetch au prochain appel', () async {
      int fetchCount = 0;

      await CacheService.getOrFetch<String>(
        key: 'test_invalidate',
        ttl: const Duration(hours: 1),
        fetcher: () async { fetchCount++; return 'v1'; },
      );

      await CacheService.invalidate('test_invalidate');

      await CacheService.getOrFetch<String>(
        key: 'test_invalidate',
        ttl: const Duration(hours: 1),
        fetcher: () async { fetchCount++; return 'v2'; },
      );

      expect(fetchCount, equals(2)); // Re-fetch après invalidation
    });

    test('clearAll vide toutes les clés du cache', () async {
      await CacheService.write('key1', 'value1');
      await CacheService.write('key2', 'value2');
      await CacheService.clearAll();

      final v1 = await CacheService.read<String>('key1');
      final v2 = await CacheService.read<String>('key2');

      expect(v1, isNull);
      expect(v2, isNull);
    });
  });

  group('CacheResult', () {
    test('isOffline est true seulement si offline ET data non null', () {
      const withData = CacheResult<String>(
          data: 'test', status: CacheStatus.offline);
      const withoutData = CacheResult<String>(
          data: null, status: CacheStatus.offline);
      const fresh = CacheResult<String>(
          data: 'test', status: CacheStatus.fresh);

      expect(withData.isOffline, isTrue);
      expect(withoutData.isOffline, isFalse);
      expect(fresh.isOffline, isFalse);
    });

    test('fromCache est true pour stale et offline, false pour fresh', () {
      const fresh = CacheResult<int>(data: 1, status: CacheStatus.fresh);
      const stale = CacheResult<int>(data: 1, status: CacheStatus.stale);
      const offline = CacheResult<int>(data: 1, status: CacheStatus.offline);

      expect(fresh.fromCache, isFalse);
      expect(stale.fromCache, isTrue);
      expect(offline.fromCache, isTrue);
    });
  });
}
