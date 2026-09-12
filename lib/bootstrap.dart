import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/dio_factory.dart';
import 'core/network/network_info.dart';
import 'core/session/session_manager.dart';
import 'core/storage/hive_boxes.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/favorites/data/datasources/favorite_local_data_source.dart';
import 'features/favorites/data/datasources/favorite_remote_data_source.dart';
import 'features/favorites/data/repositories/favorite_repository_impl.dart';
import 'features/favorites/domain/repositories/favorite_repository.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'features/movies/data/datasources/movie_local_data_source.dart';
import 'features/movies/data/datasources/movie_remote_data_source.dart';
import 'features/movies/data/repositories/movie_repository_impl.dart';
import 'features/movies/domain/repositories/movie_repository.dart';
import 'features/movies/presentation/controllers/movies_controller.dart';
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromDartDefine();

  await initHive();

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final sessionManager = SessionManager(secureStorage);

  final dioFactory = DioFactory(config);
  final authDio = dioFactory.createAuthClient();
  final authRemote = AuthRemoteDataSourceImpl(authDio);

  final apiDio = dioFactory.createApiClient(
    sessionManager: sessionManager,
    refresher: authRemote,
    retryClient: dioFactory.createRetryClient(),
  );

  final NetworkInfo networkInfo = ConnectivityNetworkInfo(Connectivity());

  final AuthRepository authRepository = AuthRepositoryImpl(
    remote: authRemote,
    sessionManager: sessionManager,
    clearCaches: clearAllCaches,
  );

  final MovieRepository movieRepository = MovieRepositoryImpl(
    remote: MovieRemoteDataSourceImpl(apiDio),
    local: MovieLocalDataSourceImpl(),
    networkInfo: networkInfo,
  );

  final FavoriteRepository favoriteRepository = FavoriteRepositoryImpl(
    remote: FavoriteRemoteDataSourceImpl(apiDio),
    local: FavoriteLocalDataSourceImpl(),
    networkInfo: networkInfo,
  );

  final ProfileRepository profileRepository = ProfileRepositoryImpl(
    remote: ProfileRemoteDataSourceImpl(apiDio),
    local: ProfileLocalDataSourceImpl(),
    networkInfo: networkInfo,
  );

  final authController = AuthController(authRepository);
  await authController.bootstrap();

  return MultiProvider(
    providers: [
      Provider<NetworkInfo>.value(value: networkInfo),
      Provider<MovieRepository>.value(value: movieRepository),
      Provider<FavoriteRepository>.value(value: favoriteRepository),
      Provider<ProfileRepository>.value(value: profileRepository),
      Provider<AuthRepository>.value(value: authRepository),
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<MoviesController>(
        create: (_) => MoviesController(movieRepository),
      ),
      ChangeNotifierProvider<FavoritesController>(
        create: (_) => FavoritesController(favoriteRepository),
      ),
      ChangeNotifierProvider<ProfileController>(
        create: (_) => ProfileController(profileRepository),
      ),
    ],
    child: const CineClubApp(),
  );
}
