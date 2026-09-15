import 'package:flutter/material.dart';

/// Affiche d'un film, optimisée pour le défilement.
///
/// Trois points comptent pour tenir 60 fps sur une liste :
///
/// 1. **Décodage à la taille d'affichage.** `cacheWidth` / `cacheHeight`
///    demandent au moteur de redimensionner l'image *pendant* le décodage.
///    Sans eux, une affiche 780×1170 est décodée en entier (≈ 3,6 Mo en RAM)
///    puis réduite au moment du dessin : mémoire gaspillée et pics GC visibles.
///    Les valeurs sont multipliées par le `devicePixelRatio` pour rester nettes
///    sur écran haute densité.
///    Référence : https://api.flutter.dev/flutter/widgets/Image/Image.network.html
///
/// 2. **Taille réservée d'avance.** Le placeholder occupe exactement la place
///    de l'image finale. Sans cela, l'arrivée de chaque image change la hauteur
///    de la ligne et provoque un re-layout de toute la liste — la cause la plus
///    fréquente de jank au scroll.
///
/// 3. **Chargement paresseux.** Aucune préparation ici : c'est `ListView.builder`
///    qui ne construit que les éléments visibles, donc seules les affiches à
///    l'écran (plus le cache-extent) déclenchent une requête réseau.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.semanticLabel,
    this.borderRadius = 6,
  });

  final String? url;
  final double width;
  final double height;

  /// Lu par les lecteurs d'écran. Décrit le film, pas le fichier image.
  final String semanticLabel;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(width: width, height: height);
    final source = url;

    if (source == null || source.isEmpty) return placeholder;

    final ratio = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: (width * ratio).round(),
        cacheHeight: (height * ratio).round(),
        semanticLabel: semanticLabel,
        // Garde l'image précédente pendant le rechargement : évite un
        // clignotement blanc quand l'URL change.
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        // Icône décorative : masquée aux lecteurs d'écran, le libellé utile
        // est porté par `PosterImage.semanticLabel`.
        child: const ExcludeSemantics(child: Icon(Icons.movie_outlined)),
      );
}
