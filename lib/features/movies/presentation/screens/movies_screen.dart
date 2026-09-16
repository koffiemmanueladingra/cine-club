import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/movie.dart';
import '../controllers/movies_controller.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalogTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Semantics(
              textField: true,
              label: l10n.searchFieldSemantics,
              child: TextField(
                onChanged: context.read<MoviesController>().search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: const _MovieList(),
    );
  }
}

class _MovieList extends StatelessWidget {
  const _MovieList();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoviesController>();
    final l10n = AppLocalizations.of(context);

    return AsyncView<List<Movie>>(
      state: controller.state,
      onRetry: () => controller.load(forceRefresh: true),
      builder: (context, _) {
        final movies = controller.visibleMovies;
        if (movies.isEmpty) {
          return _EmptyList(message: l10n.emptyCatalog);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieRow(key: ValueKey(movie.id), movie: movie);
          },
        );
      },
    );
  }
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesController, bool>(
      (c) => c.favoriteMovieIds.contains(movie.id),
    );

    return MovieCard(
      movie: movie,
      isFavorite: isFavorite,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MovieDetailScreen(movieId: movie.id),
        ),
      ),
      onToggleFavorite: () => _toggle(context, movie.id),
    );
  }

  Future<void> _toggle(BuildContext context, String movieId) async {
    final favorites = context.read<FavoritesController>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final success = await favorites.toggle(movieId);
    if (success) return;

    final failure = favorites.actionFailure;
    if (failure == null) return;
    favorites.clearActionFailure();
    messenger.showSnackBar(
      SnackBar(content: Text(failure.localizedMessage(l10n))),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(message)),
        ],
      );
}
