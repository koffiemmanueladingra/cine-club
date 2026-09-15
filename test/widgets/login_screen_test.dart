import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cine_club/features/auth/presentation/screens/login_screen.dart';
import 'package:cine_club/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = FakeAuthRepository();
    controller = AuthController(repository);
  });

  tearDown(() {
    controller.dispose();
    repository.dispose();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Locale locale = const Locale('fr'),
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: controller,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('un formulaire vide affiche les deux erreurs de validation',
      (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('un e-mail sans arobase est rejeté avant tout appel réseau',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ada.example.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Adresse e-mail invalide.'), findsOneWidget);
    expect(repository.currentUser, isNull);
  });

  testWidgets('un formulaire valide déclenche la connexion', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(controller.status, AuthStatus.authenticated);
  });

  testWidgets('un échec de connexion est affiché en clair', (tester) async {
    repository.loginFailure = const AuthFailure(
      'E-mail ou mot de passe incorrect.',
      code: FailureCode.serverMessage,
    );
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'faux');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('le bouton œil bascule le masquage du mot de passe',
      (tester) async {
    await pumpLogin(tester);

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('tout l\'écran bascule en anglais avec la locale en',
      (tester) async {
    await pumpLogin(tester, locale: const Locale('en'));

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign in to browse the catalog.'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    // Aucun reliquat français ne doit subsister.
    expect(find.text('Se connecter'), findsNothing);
  });
}
