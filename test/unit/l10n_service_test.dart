// test/unit/l10n_service_test.dart
// Tests unitaires pour L10nService (internationalisation)
// Lancer avec : flutter test test/unit/l10n_service_test.dart
//
// API réelle : L10n.setLocale(String) / L10n.locale / L10n.tr(String)

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_rewind/services/l10n_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await L10n.setLocale('fr');
  });

  group('L10n — langue française (défaut)', () {
    test('locale est "fr" après setLocale("fr")', () {
      expect(L10n.locale, equals('fr'));
    });

    test('tr() retourne la traduction française pour une clé connue', () {
      expect(L10n.tr('app_name'), equals('EcoRewind'));
    });

    test('tr() retourne la clé elle-même si introuvable', () {
      expect(L10n.tr('clé_inexistante_xyz'), equals('clé_inexistante_xyz'));
    });

    test('tr() ne retourne jamais null', () {
      expect(L10n.tr('some_unknown_key'), isNotNull);
    });

    test('Clés d\'erreur existent en français', () {
      for (final key in ['err_network', 'err_server', 'err_unauthorized', 'err_unknown']) {
        final value = L10n.tr(key);
        expect(value, isNot(equals(key)),
            reason: 'Clé $key doit avoir une traduction FR');
        expect(value.isNotEmpty, isTrue);
      }
    });

    test('Clés d\'actions communes existent en français', () {
      for (final key in ['btn_save', 'btn_cancel', 'btn_confirm', 'btn_close', 'btn_edit']) {
        final value = L10n.tr(key);
        expect(value, isNot(equals(key)),
            reason: 'Clé $key doit être traduite en FR');
      }
    });

    test('Clés hors-ligne existent', () {
      expect(L10n.tr('offline_banner'), isNot(equals('offline_banner')));
      expect(L10n.tr('offline_retry'), isNot(equals('offline_retry')));
    });

    test('Clés admin existent', () {
      for (final key in ['user_mgmt_title', 'mod_pending', 'mod_approve', 'mod_reject']) {
        expect(L10n.tr(key), isNot(equals(key)));
      }
    });

    test('Clés chargement existent', () {
      expect(L10n.tr('loading'), isNot(equals('loading')));
      expect(L10n.tr('no_data'), isNot(equals('no_data')));
    });
  });

  group('L10n — robustesse', () {
    test('Langue inconnue → fallback sur la clé (pas de crash)', () async {
      await L10n.setLocale('zh');
      expect(() => L10n.tr('app_name'), returnsNormally);
      await L10n.setLocale('fr');
    });

    test('Les listeners sont notifiés lors du changement de langue', () async {
      int callCount = 0;
      void listener() => callCount++;

      L10n.addListener(listener);
      await L10n.setLocale('fr');
      await L10n.setLocale('fr');

      expect(callCount, equals(2));
      L10n.removeListener(listener);
    });
  });
}
