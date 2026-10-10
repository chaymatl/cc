import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Configuration de l'API backend
class ApiConstants {
  // ⚠️ CONFIGURATION IMPORTANTE:
  // - Pour ÉMULATEUR Android  → utiliser 10.0.2.2 (adresse spéciale)
  // - Pour APPAREIL PHYSIQUE  → utiliser l'IP locale de votre PC (ex: 192.168.1.X)
  //   Trouvez votre IP avec: ipconfig (Windows) → cherchez 'Adresse IPv4' (Wi-Fi)
  static const String _physicalDeviceIp = '127.0.0.1'; // ← ADB Reverse (USB)

  // Mettez à true si vous testez sur un APPAREIL PHYSIQUE (pas un émulateur)
  static const bool usePhysicalDevice = true;

  /// URL du serveur (Android/iOS uniquement)
  static String get baseUrl => _getNativeBaseUrl();

  /// URL pour mobile
  static String _getNativeBaseUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (usePhysicalDevice) {
        return 'http://$_physicalDeviceIp:8000';
      } else {
        return 'http://10.0.2.2:8000';
      }
    }
    // iOS
    return 'http://localhost:8000';
  }

  /// URL alternative pour appareil physique Android (fallback Facebook auth)
  static String get physicalDeviceUrl => 'http://$_physicalDeviceIp:8000';

  /// URL de l'émulateur Android
  static String get emulatorUrl => 'http://10.0.2.2:8000';

  /// Résout une URL partielle (ex: /uploads/img.jpg) en URL absolue.
  /// Préfixe avec baseUrl → http://127.0.0.1:8000/uploads/img.jpg
  static String resolveUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${baseUrl.replaceAll(RegExp(r'/$'), '')}$url';
  }
}
