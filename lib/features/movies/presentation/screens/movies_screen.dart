import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/movie.dart';
import '../controllers/movies_controller.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoviesController>();
    final favorites = context.watch<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: controller.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher un titre ou un genre',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: AsyncView<List<Movie>>(
        state: controller.state,
        onRetry: () => controller.load(forceRefresh: true),
        builder: (context, _) {
          final movies = controller.visibleMovies;
          if (movies.isEmpty) {
            return const _EmptyList(message: 'Aucun film ne correspond.');
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                isFavorite: favorites.favoriteMovieIds.contains(movie.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MovieDetailScreen(movieId: movie.id),
                  ),
                ),
                onToggleFavorite: () => _toggle(context, movie.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggle(BuildContext context, String movieId) async {
    final favorites = context.read<FavoritesController>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await favorites.toggle(movieId);
    if (success) return;

    final failure = favorites.actionFailure;
    if (failure == null) return;
    favorites.clearActionFailure();
    messenger.showSnackBar(SnackBar(content: Text(failure.message)));
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
