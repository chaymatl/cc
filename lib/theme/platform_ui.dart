import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Utilitaire de détection plateforme + responsive.
class PlatformUI {
  /// True si on est en mode web (navigateur).
  static bool get isWeb => kIsWeb;

  /// True si on est sur mobile natif (Android/iOS).
  static bool get isMobile => !kIsWeb;

  /// True si l'écran est large (desktop/tablette paysage).
  static bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width > 900;

  /// True si on doit afficher le layout web (sidebar + contenu).
  /// Condition : on est sur le web ET l'écran est large.
  static bool shouldUseWebLayout(BuildContext context) =>
      isWeb && isWideScreen(context);
}
