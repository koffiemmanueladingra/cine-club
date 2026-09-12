import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class HiveBoxes {
  const HiveBoxes._();

  static const String movies = 'movies_cache_v1';

  static const String favorites = 'favorites_cache_v1';

  static const String profile = 'profile_cache_v1';

  static const String meta = 'cache_meta_v1';

  static const List<String> all = [movies, favorites, profile, meta];
}

Future<void> initHive() async {
  await Hive.initFlutter();
  for (final name in HiveBoxes.all) {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<String>(name);
    }
  }
}

Future<void> clearAllCaches() async {
  for (final name in HiveBoxes.all) {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<String>(name).clear();
    }
  }
}
