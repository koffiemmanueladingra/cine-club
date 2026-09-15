import 'package:flutter/material.dart';

import '../../../../core/widgets/poster_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/movie.dart';
import 'movie_meta.dart';

/// Ligne de film réutilisée par le catalogue et par les favoris.
///
/// Découpage de l'accessibilité :
/// - la zone tactile principale est un unique nœud `Semantics(button: true)`
///   qui annonce titre + métadonnées, et dont les enfants sont masqués par
///   `ExcludeSemantics` — sans cela le lecteur d'écran énonce quatre nœuds
///   séparés pour une seule carte ;
/// - le bouton favori reste **en dehors** de cette zone, avec son propre
///   libellé, sinon il serait avalé par le nœud parent et deviendrait
///   inatteignable au balayage.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.isFavorite,
    this.onTap,
    this.onToggleFavorite,
  });

  final Movie movie;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  static const double posterWidth = 64;
  static const double posterHeight = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final metaLine = movieMetaLine(movie, localeName);
    final spoken = movieMetaSpoken(movie, l10n, localeName);

    final favoriteLabel =
        isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: l10n.movieCardSemantics(movie.title, spoken),
              child: InkWell(
                onTap: onTap,
                child: ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PosterImage(
                          url: movie.posterUrl,
                          width: posterWidth,
                          height: posterHeight,
                          semanticLabel: l10n.posterOf(movie.title),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: theme.textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(metaLine, style: theme.textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Text(
                                movie.overview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onToggleFavorite != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: IconButton(
                onPressed: onToggleFavorite,
                tooltip: favoriteLabel,
                // Redondant avec `tooltip` sur Android, mais `tooltip` n'est
                // pas exposé de la même façon sur toutes les plateformes ;
                // le libellé explicite garantit l'annonce partout.
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.colorScheme.primary : null,
                  semanticLabel: favoriteLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
