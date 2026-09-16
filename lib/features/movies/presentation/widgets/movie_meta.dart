import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/movie.dart';

String movieMetaLine(Movie movie, String localeName) {
  final parts = <String>[
    if (movie.releaseYear != null) '${movie.releaseYear}',
    if (movie.genre != null) movie.genre!,
    if (movie.rating != null) '★ ${formatRating(movie.rating!, localeName)}',
  ];
  return parts.join(' · ');
}

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
