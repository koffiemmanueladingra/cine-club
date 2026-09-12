import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'features/favorites/presentation/screens/favorites_screen.dart';
import 'features/movies/presentation/controllers/movies_controller.dart';
import 'features/movies/presentation/screens/movies_screen.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

class CineClubApp extends StatelessWidget {
  const CineClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CinéClub',
      debugShowCheckedModeBanner: false,
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
    final status = context.watch<AuthController>().status;

    return switch (status) {
      AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const HomeShell(),
    };
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
    _boundUserId = userId;

    context.read<FavoritesController>().bindUser(userId);
    context.read<ProfileController>().bindUser(userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MoviesController>().load();
      context.read<FavoritesController>().load();
      context.read<ProfileController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
