import 'package:cine_club/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

/// Parcours de bout en bout de l'application.
///
/// Ces tests montent le **vrai** `CineClubApp` — ses routes, son thème, ses
/// délégués de localisation, ses contrôleurs — et ne remplacent que les
/// quatre interfaces de `domain/` par des doubles en mémoire. Un test qui
/// passe ici prouve donc quelque chose sur le code de production.
///
/// ## Pourquoi un seul fichier
///
/// `flutter test integration_test` lance **une instance d'application par
/// fichier**. Sur la cible Linux desktop de la CI, exécutée sous `xvfb`, le
/// second démarrage échoue de façon reproductible :
///
///     Error waiting for a debug connection: The log reader stopped
///     unexpectedly, or never started.
///     Unable to start the app on the device.
///
/// Regrouper les parcours dans un fichier unique n'entraîne qu'un seul
/// démarrage. C'est un contournement de l'instabilité du lanceur, pas une
/// correction de sa cause : si les tests grossissent au point de justifier
/// plusieurs fichiers, il faudra passer à un émulateur Android
/// (`reactivecircus/android-emulator-runner`), plus lent mais plus stable
/// sur ce point précis.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppHarness harness;

  tearDown(() => harness.dispose());

  group('Navigation', () {
    testWidgets(
        'un visiteur se connecte, parcourt le catalogue et ouvre une fiche',
        (tester) async {
      harness = AppHarness(signedIn: false, locale: const Locale('fr'));
      harness.movies.movies = [
        movie(id: 'm-1', title: 'Metropolis'),
        movie(id: 'm-2', title: 'Nosferatu', genre: 'Horreur'),
      ];

      await harness.pumpApp(tester);

      // 1. L'application démarre sur l'écran de connexion.
      expect(find.text('Se connecter'), findsOneWidget);

      // 2. Saisie et validation.
      await tester.enterText(
        find.byType(TextFormField).first,
        'ada@example.com',
      );
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
      await tester.tap(backButton());
      await tester.pumpAndSettle();

      expect(find.byType(MovieCard), findsNWidgets(2));
    });

    testWidgets(
        'la recherche puis la déconnexion ramènent à l\'écran de connexion',
        (tester) async {
      harness = AppHarness(locale: const Locale('fr'));
      harness.movies.movies = [
        movie(id: 'm-1', title: 'Metropolis'),
        movie(id: 'm-2', title: 'Nosferatu'),
      ];

      await harness.pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'nosfe');
      await tester.pumpAndSettle();
      expect(find.byType(MovieCard), findsOneWidget);

      await tester.tap(navTab('Profil'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(find.text('Se connecter'), findsOneWidget);
    });
  });

  group('Favoris et langue', () {
    testWidgets('un favori ajouté au catalogue apparaît dans l\'onglet Favoris',
        (tester) async {
      harness = AppHarness(locale: const Locale('fr'));
      harness.movies.movies = [
        movie(id: 'm-1', title: 'Metropolis'),
        movie(id: 'm-2', title: 'Nosferatu'),
      ];

      await harness.pumpApp(tester);

      // Onglet Favoris : vide au départ.
      await tester.tap(navTab('Favoris'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun favori pour le moment.'), findsOneWidget);

      // Retour au catalogue, ajout d'un favori.
      await tester.tap(navTab('Catalogue'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      expect(harness.favorites.favorites, {'m-1'});

      // L'onglet Favoris reflète l'ajout, sans rechargement manuel.
      await tester.tap(navTab('Favoris'));
      await tester.pumpAndSettle();

      expect(find.byType(MovieCard), findsOneWidget);
      expect(find.text('Metropolis'), findsOneWidget);

      // Retrait depuis l'onglet Favoris : la liste redevient vide.
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle();

      expect(find.text('Aucun favori pour le moment.'), findsOneWidget);
      expect(harness.favorites.favorites, isEmpty);
    });

    testWidgets('changer la langue depuis le profil retraduit toute '
        'l\'application', (tester) async {
      harness = AppHarness(locale: const Locale('fr'));
      await harness.pumpApp(tester);

      expect(find.text('Catalogue'), findsWidgets);

      await tester.tap(navTab('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      // L'écran courant est retraduit...
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsNothing);

      // ...et la barre de navigation aussi, alors qu'elle vit dans un widget
      // parent : c'est ce que vérifie ce test, pas seulement le texte visible.
      expect(find.text('Catalog'), findsWidgets);
      await tester.tap(navTab('Catalog'));
      await tester.pumpAndSettle();
      expect(find.text('Search by title or genre'), findsOneWidget);
    });
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

/// Bouton retour de l'`AppBar`, indépendant de la langue.
///
/// `tester.pageBack()` ne convient pas ici : il cherche
/// `find.byTooltip('Back')` puis, en repli, un
/// `CupertinoNavigationBarBackButton`. Or l'infobulle vient de
/// `MaterialLocalizations.backButtonTooltip`, qui vaut « Retour » en
/// français — aucune des deux recherches n'aboutit, et le test échoue sur
/// « One back button expected on screen ».
///
/// `BackButton` est le widget que l'`AppBar` insère automatiquement comme
/// `leading` lorsqu'une route peut être dépilée ; le chercher par son type
/// ne dépend d'aucune traduction.
Finder backButton() => find.byType(BackButton);
