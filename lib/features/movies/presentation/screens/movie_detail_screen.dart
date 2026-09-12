import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/cached.dart';
import '../../../../core/error/result.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

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
    _future = context.read<MovieRepository>().getMovieById(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final isFavorite = favorites.favoriteMovieIds.contains(widget.movieId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          IconButton(
            onPressed: () => favorites.toggle(widget.movieId),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: FutureBuilder<Result<Cached<Movie>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data!.fold(
            ok: (cached) => _Details(cached: cached),
            err: (failure) => ErrorView(
              failure: failure,
              onRetry: () => setState(() {
                _future =
                    context.read<MovieRepository>().getMovieById(widget.movieId);
              }),
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

    return Column(
      children: [
        if (cached.fromCache) OfflineBanner(syncedAt: cached.syncedAt),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (movie.posterUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl!,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: 20),
              Text(movie.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                [
                  if (movie.releaseYear != null) '${movie.releaseYear}',
                  if (movie.genre != null) movie.genre!,
                  if (movie.rating != null)
                    '★ ${movie.rating!.toStringAsFixed(1)}/10',
                ].join(' · '),
                style: theme.textTheme.labelLarge,
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
