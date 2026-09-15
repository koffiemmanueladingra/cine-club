import 'package:cine_club/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

/// Parcours de bout en bout : connexion, catalogue, fiche, retour.
///
/// Ce test monte l'application réelle (`CineClubApp`, ses routes, son thème,
/// ses contrôleurs) et ne remplace que les quatre dépôts de `domain/`. Il
/// vérifie donc l'enchaînement des écrans, pas une maquette.
///
/// Il s'exécute sans émulateur : `flutter test integration_test` le lance dans
/// la machine virtuelle `flutter_tester`, ce qui permet de l'intégrer à la CI
/// sans provisionner d'appareil.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppHarness harness;

  tearDown(() => harness.dispose());

  testWidgets(
      'un visiteur se connecte, parcourt le catalogue et ouvre '
      'une fiche', (tester) async {
    harness = AppHarness(signedIn: false, locale: const Locale('fr'));
    harness.movies.movies = [
      movie(id: 'm-1', title: 'Metropolis'),
      movie(id: 'm-2', title: 'Nosferatu', genre: 'Horreur'),
    ];

    await harness.pumpApp(tester);

    // 1. L'application démarre sur l'écran de connexion.
    expect(find.text('Se connecter'), findsOneWidget);

    // 2. Saisie et validation.
    await tester.enterText(find.byType(TextFormField).first, 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // 3. Le catalogue est chargé et la navigation basse est en place.
    expect(find.text('Catalogue'), findsWidgets);
    expect(find.byType(MovieCard), findsNWidgets(2));

    // 4. Ouverture d'une fiche.
    await tester.tap(find.text('Metropolis'));
    await tester.pumpAndSettle();

    expect(find.text('Détail'), findsOneWidget);
    expect(find.textContaining('métropole futuriste'), findsOneWidget);

    // 5. Retour au catalogue.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsNWidgets(2));
  });

  testWidgets(
      'la recherche puis la déconnexion ramènent à l\'écran de '
      'connexion', (tester) async {
    harness = AppHarness(locale: const Locale('fr'));
    harness.movies.movies = [
      movie(id: 'm-1', title: 'Metropolis'),
      movie(id: 'm-2', title: 'Nosferatu'),
    ];

    await harness.pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'nosfe');
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsOneWidget);

    // Onglet Profil, puis déconnexion.
    await tester.tap(navTab('Profil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.text('Se connecter'), findsOneWidget);
  });
}

/// Cible un onglet de la barre de navigation par son libellé.
///
/// `find.byIcon(Icons.movie_outlined)` serait ambigu : la même icône sert de
/// placeholder d'affiche dans les cartes. `find.text('Catalogue')` le serait
/// aussi, puisque le titre de l'AppBar porte le même mot. On restreint donc
/// la recherche aux descendants de la `NavigationBar`.
Finder navTab(String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );
