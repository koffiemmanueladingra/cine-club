import 'package:cine_club/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

void main() {
  final metropolis = movie(
    id: 'm-1',
    title: 'Metropolis',
    genre: 'Science-fiction',
    releaseYear: 1927,
    rating: 8.3,
  );

  testWidgets('affiche titre, métadonnées et résumé', (tester) async {
    await pumpLocalized(
      tester,
      MovieCard(movie: metropolis, isFavorite: false),
    );

    expect(find.text('Metropolis'), findsOneWidget);
    expect(find.text('1927 · Science-fiction · ★ 8,3'), findsOneWidget);
    expect(find.textContaining('métropole futuriste'), findsOneWidget);
  });

  testWidgets('la même carte se formate en anglais avec un point décimal',
      (tester) async {
    await pumpLocalized(
      tester,
      MovieCard(movie: metropolis, isFavorite: false),
      locale: const Locale('en'),
    );

    expect(find.text('1927 · Science-fiction · ★ 8.3'), findsOneWidget);
  });

  testWidgets('expose un seul nœud sémantique bouton pour la carte',
      (tester) async {
    final handle = tester.ensureSemantics();

    await pumpLocalized(
      tester,
      MovieCard(movie: metropolis, isFavorite: false, onTap: () {}),
    );

    expect(
      find.bySemanticsLabel(
        RegExp(r'Metropolis, 1927, Science-fiction, noté 8,3 sur 10'),
      ),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('le bouton favori porte un libellé qui dépend de son état',
      (tester) async {
    final handle = tester.ensureSemantics();

    await pumpLocalized(
      tester,
      MovieCard(
        movie: metropolis,
        isFavorite: false,
        onToggleFavorite: () {},
      ),
    );
    expect(find.bySemanticsLabel('Ajouter aux favoris'), findsWidgets);

    await pumpLocalized(
      tester,
      MovieCard(
        movie: metropolis,
        isFavorite: true,
        onToggleFavorite: () {},
      ),
    );
    expect(find.bySemanticsLabel('Retirer des favoris'), findsWidgets);

    handle.dispose();
  });

  testWidgets('un appui sur le cœur déclenche onToggleFavorite, pas onTap',
      (tester) async {
    var tapped = 0;
    var toggled = 0;

    await pumpLocalized(
      tester,
      MovieCard(
        movie: metropolis,
        isFavorite: false,
        onTap: () => tapped++,
        onToggleFavorite: () => toggled++,
      ),
    );

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(toggled, 1);
    // Le bouton est hors de l'InkWell : l'appui ne doit pas ouvrir la fiche.
    expect(tapped, 0);
  });

  testWidgets('sans onToggleFavorite, aucun bouton cœur n\'est rendu',
      (tester) async {
    await pumpLocalized(
      tester,
      MovieCard(movie: metropolis, isFavorite: false),
    );

    expect(find.byType(IconButton), findsNothing);
  });
}
