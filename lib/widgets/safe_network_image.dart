import 'package:flutter/material.dart';

/// Widget simple et réutilisable pour charger des images réseau sans planter
/// sur Flutter Web (gère l'erreur de type ProgressEvent via errorBuilder).
///
/// Améliorations qualité :
///   - cacheWidth/cacheHeight pour un rendu adapté à la densité d'écran
///   - filterQuality HIGH pour un rendu net
///   - gaplessPlayback pour éviter le flash blanc au rechargement
class SafeNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const SafeNetworkImage(
    this.url, {
    Key? key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return placeholder ?? const SizedBox.shrink();

    // Calcul du cacheWidth optimal basé sur la densité d'écran
    // (évite le flou sur les écrans haute densité)
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final int? cacheW = width != null ? (width! * dpr).toInt() : null;
    final int? cacheH = height != null ? (height! * dpr).toInt() : null;

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // Rendu haute qualité (évite le pixelisé / flou sur les redimensionnements)
      filterQuality: FilterQuality.high,
      // Évite le flash blanc quand l'image est rechargée (ex: scroll retour)
      gaplessPlayback: true,
      // Taille cache optimale pour la densité d'écran
      cacheWidth: cacheW,
      cacheHeight: cacheH,
      // Sur web les erreurs réseau lèvent des ProgressEvent; errorBuilder les capture.
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? Container(color: Colors.grey.shade200);
      },
      // Affiche un placeholder fluide pendant le chargement
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final double? progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null;
        return placeholder ??
            Container(
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade400,
                    ),
                  ),
                ),
              ),
            );
      },
    );
  }
}

class SafeNetworkCircleAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final Widget? placeholder;

  const SafeNetworkCircleAvatar({Key? key, required this.url, this.radius = 20, this.placeholder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: SafeNetworkImage(url, placeholder: placeholder ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
