import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/settings/locale_controller.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'features/favorites/presentation/screens/favorites_screen.dart';
import 'features/movies/presentation/controllers/movies_controller.dart';
import 'features/movies/presentation/screens/movies_screen.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'l10n/app_localizations.dart';

class CineClubApp extends StatelessWidget {
  const CineClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<LocaleController, Locale?>((c) => c.locale);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthController, AuthStatus>((c) => c.status);

    return switch (status) {
      AuthStatus.unknown => const _FullScreenLoader(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const HomeShell(),
    };
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.loading),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  String? _boundUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userId = context.read<AuthController>().user?.id;
    if (userId == null || userId == _boundUserId) return;

    // Marqué AVANT le callback : `didChangeDependencies` peut être rappelé
    // plusieurs fois avant que la frame ne soit dessinée, et sans ce garde
    // on empilerait plusieurs chargements pour le même utilisateur.
    _boundUserId = userId;

    // Tout est reporté après la frame courante, y compris `bindUser`.
    //
    // `didChangeDependencies` s'exécute PENDANT la construction (il est
    // appelé depuis `StatefulElement._firstBuild`). `bindUser` termine par
    // `notifyListeners()`, ce qui demande à Provider de marquer ses
    // descendants comme « à reconstruire » — en pleine phase de build.
    // Flutter lève alors :
    //   « setState() or markNeedsBuild() called during build ».
    //
    // Les contrôleurs restent donc à l'état `idle` le temps d'une frame :
    // `AsyncView` affiche son indicateur de chargement, ce qui est
    // exactement le comportement voulu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<FavoritesController>().bindUser(userId);
      context.read<ProfileController>().bindUser(userId);

      context.read<MoviesController>().load();
      context.read<FavoritesController>().load();
      context.read<ProfileController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          MoviesScreen(),
          FavoritesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon: const Icon(Icons.movie),
            label: l10n.navCatalog,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
