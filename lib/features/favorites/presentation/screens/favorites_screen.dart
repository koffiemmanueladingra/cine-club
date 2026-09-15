import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../movies/presentation/screens/movie_detail_screen.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../../domain/entities/favorite_movie.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: const _FavoritesList(),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritesController>();
    final l10n = AppLocalizations.of(context);

    return AsyncView<List<FavoriteMovie>>(
      state: controller.state,
      onRetry: controller.load,
      builder: (context, favorites) {
        if (favorites.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text(l10n.emptyFavorites)),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return MovieCard(
              key: ValueKey(favorite.favoriteId),
              movie: favorite.movie,
              // Sur cet écran, tout élément listé est par définition un
              // favori : pas besoin d'interroger le contrôleur.
              isFavorite: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MovieDetailScreen(movieId: favorite.movie.id),
                ),
              ),
              onToggleFavorite: () => _toggle(context, favorite.movie.id),
            );
          },
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context, String movieId) async {
    final controller = context.read<FavoritesController>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final ok = await controller.toggle(movieId);
    if (ok) return;

    final failure = controller.actionFailure;
    if (failure == null) return;
    controller.clearActionFailure();
    messenger.showSnackBar(
      SnackBar(content: Text(failure.localizedMessage(l10n))),
    );
  }
}
