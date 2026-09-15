import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/movie.dart';

/// Ligne compacte affichée sous le titre : `1927 · Science-fiction · ★ 8,3`.
///
/// La note passe par `intl.NumberFormat` : le séparateur décimal est une
/// virgule en français et un point en anglais. `toStringAsFixed` produisait un
/// point dans les deux cas.
String movieMetaLine(Movie movie, String localeName) {
  final parts = <String>[
    if (movie.releaseYear != null) '${movie.releaseYear}',
    if (movie.genre != null) movie.genre!,
    if (movie.rating != null) '★ ${formatRating(movie.rating!, localeName)}',
  ];
  return parts.join(' · ');
}

/// Même information, mais destinée à être lue à voix haute.
///
/// Un lecteur d'écran prononce mal `★ 8,3` ; on lui donne « noté 8,3 sur 10 ».
String movieMetaSpoken(
  Movie movie,
  AppLocalizations l10n,
  String localeName,
) {
  final parts = <String>[
    if (movie.releaseYear != null) '${movie.releaseYear}',
    if (movie.genre != null) movie.genre!,
    if (movie.rating != null)
      l10n.ratingOutOfTen(formatRating(movie.rating!, localeName)),
  ];
  return parts.join(', ');
}

String formatRating(double rating, String localeName) =>
    intl.NumberFormat('0.0', localeName).format(rating);
