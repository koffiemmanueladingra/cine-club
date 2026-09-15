import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:cine_club/features/movies/domain/repositories/movie_repository.dart';
import 'package:cine_club/features/movies/presentation/controllers/movies_controller.dart';
import 'package:cine_club/features/movies/presentation/screens/movies_screen.dart';
import 'package:cine_club/features/movies/presentation/widgets/movie_card.dart';
import 'package:cine_club/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

void main() {
  late FakeMovieRepository movieRepository;
  late FakeFavoriteRepository favoriteRepository;
  late MoviesController movies;
  late FavoritesController favorites;

  final metropolis =
      movie(id: 'm-1', title: 'Metropolis', genre: 'Science-fiction');
  final nosferatu = movie(id: 'm-2', title: 'Nosferatu', genre: 'Horreur');

  setUp(() {
    movieRepository = FakeMovieRepository(movies: [metropolis, nosferatu]);
    favoriteRepository = FakeFavoriteRepository(
      catalogue: [metropolis, nosferatu],
    );
    movies = MoviesController(movieRepository);
    favorites = FavoritesController(favoriteRepository)..bindUser('u-1');
  });

  Future<void> pumpCatalog(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<MovieRepository>.value(value: movieRepository),
          ChangeNotifierProvider<MoviesController>.value(value: movies),
          ChangeNotifierProvider<FavoritesController>.value(value: favorites),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MoviesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche une carte par film chargé', (tester) async {
    await movies.load();
    await favorites.load();
    await pumpCatalog(tester);

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('Metropolis'), findsOneWidget);
    expect(find.text('Nosferatu'), findsOneWidget);
  });

  testWidgets('la recherche filtre la liste affichée', (tester) async {
    await movies.load();
    await favorites.load();
    await pumpCatalog(tester);

    await tester.enterText(find.byType(TextField), 'nosfe');
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('Nosferatu'), findsOneWidget);
  });

  testWidgets('une recherche sans résultat affiche le message vide',
      (tester) async {
    await movies.load();
    await favorites.load();
    await pumpCatalog(tester);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsNothing);
    expect(find.text('Aucun film ne correspond.'), findsOneWidget);
  });

  testWidgets('appuyer sur le cœur ajoute le film aux favoris', (tester) async {
    await movies.load();
    await favorites.load();
    await pumpCatalog(tester);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    expect(favoriteRepository.favorites, contains('m-1'));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('un échec d\'ajout affiche un SnackBar traduit', (tester) async {
    await movies.load();
    await favorites.load();
    favoriteRepository.writeFailure = const NetworkFailure(
      'hors ligne',
      code: FailureCode.writeOffline,
    );
    await pumpCatalog(tester);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    expect(
      find.text('Cette modification nécessite une connexion Internet.'),
      findsOneWidget,
    );
  });

  testWidgets('une erreur de chargement affiche l\'écran d\'erreur',
      (tester) async {
    movieRepository.failure = const NetworkFailure(
      'x',
      code: FailureCode.connection,
    );
    await movies.load();
    await pumpCatalog(tester);

    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });
}
