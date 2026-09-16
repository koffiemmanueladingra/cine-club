import 'package:flutter/material.dart';

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
        child: const ExcludeSemantics(child: Icon(Icons.movie_outlined)),
      );
}
