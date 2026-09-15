import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/cached.dart';
import '../../../../core/error/result.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/poster_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../widgets/movie_meta.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Result<Cached<Movie>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Result<Cached<Movie>>> _load() =>
      context.read<MovieRepository>().getMovieById(widget.movieId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final isFavorite = context.select<FavoritesController, bool>(
      (c) => c.favoriteMovieIds.contains(widget.movieId),
    );
    final favoriteLabel =
        isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.movieDetailTitle),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<FavoritesController>().toggle(widget.movieId),
            tooltip: favoriteLabel,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              semanticLabel: favoriteLabel,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Result<Cached<Movie>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          return snapshot.data!.fold(
            ok: (cached) => _Details(cached: cached),
            err: (failure) => ErrorView(
              failure: failure,
              onRetry: () => setState(() => _future = _load()),
            ),
          );
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.cached});

  final Cached<Movie> cached;

  @override
  Widget build(BuildContext context) {
    final movie = cached.data;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    return Column(
      children: [
        if (cached.fromCache) OfflineBanner(syncedAt: cached.syncedAt),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (movie.posterUrl != null)
                Center(
                  child: PosterImage(
                    url: movie.posterUrl,
                    width: 220 * 2 / 3,
                    height: 220,
                    borderRadius: 12,
                    semanticLabel: l10n.posterOf(movie.title),
                  ),
                ),
              const SizedBox(height: 20),
              // `header: true` permet de sauter directement au titre avec les
              // gestes de navigation par titres de TalkBack / VoiceOver.
              Semantics(
                header: true,
                child: Text(movie.title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: movieMetaSpoken(movie, l10n, localeName),
                child: ExcludeSemantics(
                  child: Text(
                    movieMetaLine(movie, localeName),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(movie.overview, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
