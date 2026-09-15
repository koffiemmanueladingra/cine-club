import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/widgets/error_view.dart';
import 'package:cine_club/core/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('ErrorView', () {
    testWidgets('traduit le message à partir du code, pas du texte stocké',
        (tester) async {
      // Le message stocké est en français ; l'écran est en anglais.
      // Si l'écran affichait `failure.message`, ce test échouerait.
      const failure = NetworkFailure(
        'Impossible de joindre le serveur.',
        code: FailureCode.connection,
      );

      await pumpLocalized(
        tester,
        const ErrorView(failure: failure),
        locale: const Locale('en'),
      );

      expect(
        find.text('Cannot reach the server. Check your internet connection.'),
        findsOneWidget,
      );
      expect(find.text('Impossible de joindre le serveur.'), findsNothing);
    });

    testWidgets('affiche le texte du serveur tel quel quand il est présent',
        (tester) async {
      // `serverMessage` signale un texte venu de Supabase : intraduisible,
      // donc affiché sans transformation, même en anglais.
      const failure = AuthFailure(
        'Invalid login credentials',
        code: FailureCode.serverMessage,
      );

      await pumpLocalized(
        tester,
        const ErrorView(failure: failure),
        locale: const Locale('en'),
      );

      expect(find.text('Invalid login credentials'), findsOneWidget);
    });

    testWidgets('interpole le code HTTP dans le message de rejet',
        (tester) async {
      const failure = ServerFailure(
        'refusé',
        statusCode: 418,
        code: FailureCode.requestRejected,
        detail: '418',
      );

      await pumpLocalized(tester, const ErrorView(failure: failure));

      expect(find.text('La requête a été refusée (code 418).'), findsOneWidget);
    });

    testWidgets('le bouton Réessayer n\'existe que si onRetry est fourni',
        (tester) async {
      const failure = NetworkFailure('x', code: FailureCode.timeout);

      await pumpLocalized(tester, const ErrorView(failure: failure));
      expect(find.text('Réessayer'), findsNothing);

      var retried = 0;
      await pumpLocalized(
        tester,
        ErrorView(failure: failure, onRetry: () => retried++),
      );
      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      expect(retried, 1);
    });

    testWidgets('choisit une icône selon le type d\'échec', (tester) async {
      await pumpLocalized(
        tester,
        const ErrorView(
          failure: NetworkFailure('x', code: FailureCode.connection),
        ),
      );
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);

      await pumpLocalized(
        tester,
        const ErrorView(
          failure: EmptyCacheFailure('x', code: FailureCode.catalogOffline),
        ),
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('OfflineBanner', () {
    testWidgets('sans date, affiche le message générique', (tester) async {
      await pumpLocalized(tester, const OfflineBanner());

      expect(
        find.text('Mode hors ligne — données enregistrées sur l\'appareil.'),
        findsOneWidget,
      );
    });

    testWidgets('formate la date selon la locale active', (tester) async {
      // Heure *locale* et non UTC : le widget appelle `toLocal()`, un
      // `DateTime.utc` ferait dépendre le test du fuseau de la machine.
      final synced = DateTime(2026, 1, 15, 10, 30);

      await pumpLocalized(
        tester,
        OfflineBanner(syncedAt: synced),
        locale: const Locale('fr'),
      );
      // Format français : jour/mois/année, horloge 24 h.
      expect(find.textContaining('15/01/2026'), findsOneWidget);

      await pumpLocalized(
        tester,
        OfflineBanner(syncedAt: synced),
        locale: const Locale('en'),
      );
      // Format anglais : mois/jour/année.
      expect(find.textContaining('1/15/2026'), findsOneWidget);
    });
  });
}
