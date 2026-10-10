import 'package:flutter/material.dart';

/// Bouton retour mobile — compatible Android et iOS.
///
/// Usage dans un AppBar :
///   leading: const WebBackButton(),
class WebBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final IconData icon;

  const WebBackButton({super.key,
    this.color,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_new_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

/// Retourne toujours le widget fourni (suppression du comportement web).
///
/// Usage :
///   leading: webLeading(IconButton(...)),
Widget webLeading(Widget child) => child;
