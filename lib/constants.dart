import 'package:flutter/foundation.dart';

/// Configuration de l'API backend
class ApiConstants {
  // ⚠️ CONFIGURATION IMPORTANTE:
  // - Pour ÉMULATEUR Android  → utiliser 10.0.2.2 (adresse spéciale)
  // - Pour APPAREIL PHYSIQUE  → utiliser l'IP locale de votre PC (ex: 192.168.1.X)
  //   Trouvez votre IP avec: ipconfig (Windows) → cherchez "Adresse IPv4" (Wi-Fi)
  static const String _physicalDeviceIp = "127.0.0.1"; // ← ADB Reverse (USB) — voir ci-dessous

  // Mettez à true si vous testez sur un APPAREIL PHYSIQUE (pas un émulateur)
  static const bool usePhysicalDevice = true;

  /// URL du serveur selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      // Web: utiliser dynamiquement l'hôte actuel (fonctionne en local ET en production)
      return _getWebBaseUrl();
    }

    // Mobile/Desktop: import conditionnel pour éviter dart:io sur le web
    return _getNativeBaseUrl();
  }

  /// URL pour le web: détecte automatiquement l'hôte du navigateur
  static String _getWebBaseUrl() {
    // En mode web, on utilise le même hôte que l'application
    // Cela fonctionne automatiquement en local (localhost) et en production
    try {
      // ignore: avoid_web_libraries_in_flutter
      final uri = Uri.base;
      final host = uri.host;
      final isLocalhost = host == 'localhost' || host == '127.0.0.1';

      if (isLocalhost) {
        // En développement local, le backend tourne sur le port 8000
        return "http://${uri.host}:8000";
      } else {
        // En production, le backend est sur le même domaine ou un sous-domaine
        // Ajuster selon votre configuration de déploiement
        return "${uri.scheme}://$host:8000";
      }
    } catch (_) {
      return "http://localhost:8000";
    }
  }

  /// URL pour mobile/desktop
  static String _getNativeBaseUrl() {
    // On doit importer dart:io conditionnellement
    // Pour simplifier, on utilise defaultTargetPlatform
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (usePhysicalDevice) {
        // Appareil physique Android via Wi-Fi
        return "http://$_physicalDeviceIp:8000";
      } else {
        // Émulateur Android : 10.0.2.2 = localhost de la machine hôte
        return "http://10.0.2.2:8000";
      }
    }
    // iOS, Windows, macOS, Linux
    return "http://localhost:8000";
  }

  /// URL alternative pour appareil physique Android (fallback Facebook auth)
  static String get physicalDeviceUrl => 'http://$_physicalDeviceIp:8000';

  /// URL de l'émulateur Android
  static String get emulatorUrl => 'http://10.0.2.2:8000';

  /// Résout une URL partielle (ex: /uploads/img.jpg) en URL absolue.
  /// - Sur Web  : retournée telle quelle (le navigateur la résout depuis window.location).
  /// - Sur Mobile : préfixe avec baseUrl → http://127.0.0.1:8000/uploads/img.jpg
  static String resolveUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (kIsWeb) return url;
    return '${baseUrl.replaceAll(RegExp(r'/$'), '')}$url';
  }
}
