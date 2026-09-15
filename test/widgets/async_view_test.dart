import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/state/async_state.dart';
import 'package:cine_club/core/widgets/async_view.dart';
import 'package:cine_club/core/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Widget viewOf(AsyncState<String> state, {Future<void> Function()? onRetry}) =>
      AsyncView<String>(
        state: state,
        onRetry: onRetry,
        builder: (_, data) => ListView(children: [Text(data)]),
      );

  testWidgets('sans données, affiche un indicateur de chargement libellé',
      (tester) async {
    await pumpLocalized(tester, viewOf(const AsyncState<String>()));

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    // Sans `semanticsLabel`, un lecteur d'écran n'annonce rien pendant
    // l'attente : l'utilisateur ne sait pas que l'application travaille.
    expect(indicator.semanticsLabel, 'Chargement');
  });

  testWidgets('en erreur sans données, affiche ErrorView', (tester) async {
    const state = AsyncState<String>(
      status: LoadStatus.error,
      failure: NetworkFailure('x', code: FailureCode.connection),
    );

    await pumpLocalized(tester, viewOf(state));

    expect(
      find.text('Impossible de joindre le serveur. '
          'Vérifiez votre connexion Internet.'),
      findsOneWidget,
    );
  });

  testWidgets('en erreur AVEC données, garde les données visibles',
      (tester) async {
    const state = AsyncState<String>(
      status: LoadStatus.error,
      data: 'contenu du cache',
      failure: NetworkFailure('x', code: FailureCode.connection),
    );

    await pumpLocalized(tester, viewOf(state));

    // Règle métier : une erreur ne fait jamais disparaître ce qui est déjà
    // affiché. C'est ce qui rend le mode hors ligne utilisable.
    expect(find.text('contenu du cache'), findsOneWidget);
    expect(find.textContaining('Impossible de joindre'), findsNothing);
  });

  testWidgets('les données issues du cache affichent le bandeau hors ligne',
      (tester) async {
    final state = AsyncState<String>(
      status: LoadStatus.ready,
      data: 'contenu',
      fromCache: true,
      syncedAt: DateTime(2026, 1, 15, 10, 30),
    );

    await pumpLocalized(tester, viewOf(state));

    expect(find.byType(OfflineBanner), findsOneWidget);
  });

  testWidgets('un rechargement en cours ajoute une barre de progression fine',
      (tester) async {
    const state = AsyncState<String>(
      status: LoadStatus.loading,
      data: 'contenu',
    );

    await pumpLocalized(tester, viewOf(state));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('contenu'), findsOneWidget);
  });

  testWidgets('onRetry active le tirer-pour-rafraîchir', (tester) async {
    const state = AsyncState<String>(
      status: LoadStatus.ready,
      data: 'contenu',
    );

    await pumpLocalized(tester, viewOf(state, onRetry: () async {}));

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
