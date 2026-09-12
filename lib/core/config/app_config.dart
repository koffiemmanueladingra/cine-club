class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseKey,
  });

  final String supabaseUrl;

  final String supabaseKey;

  factory AppConfig.fromDartDefine() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_KEY');

    if (url.isEmpty || key.isEmpty) {
      throw StateError(
        'Configuration manquante. Lancez l\'application avec :\n'
        '  flutter run --dart-define-from-file=env.json\n'
        '(copiez env.example.json vers env.json et remplissez-le).',
      );
    }
    return AppConfig(
      supabaseUrl: url.endsWith('/') ? url.substring(0, url.length - 1) : url,
      supabaseKey: key,
    );
  }

  String get authBaseUrl => '$supabaseUrl/auth/v1';

  String get restBaseUrl => '$supabaseUrl/rest/v1';
}
