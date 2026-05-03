import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Bouton retour conditionnel : visible sur mobile, invisible sur web.
/// Sur Chrome, la flèche native du navigateur et le rechargement suffisent.
///
/// Usage dans un AppBar :
///   leading: const WebBackButton(),
///
/// Usage inline (bouton flottant, etc.) :
///   if (!kIsWeb) const WebBackButton(),
class WebBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final IconData icon;

  const WebBackButton({
    Key? key,
    this.color,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_new_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink(); // Caché sur le web
    return IconButton(
      icon: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

/// Retourne SizedBox.shrink() sur web (empêche Flutter d'auto-ajouter un Back),
/// ou le widget fourni sur mobile.
///
/// Usage :
///   leading: webLeading(IconButton(...)),
Widget webLeading(Widget child) => kIsWeb ? const SizedBox.shrink() : child;
