import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../movies/presentation/screens/movie_detail_screen.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../../domain/entities/favorite_movie.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritesController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: AsyncView<List<FavoriteMovie>>(
        state: controller.state,
        onRetry: controller.load,
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Aucun favori pour le moment.')),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return MovieCard(
                movie: favorite.movie,
                isFavorite: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        MovieDetailScreen(movieId: favorite.movie.id),
                  ),
                ),
                onToggleFavorite: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await controller.toggle(favorite.movie.id);
                  final failure = controller.actionFailure;
                  if (!ok && failure != null) {
                    controller.clearActionFailure();
                    messenger.showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
