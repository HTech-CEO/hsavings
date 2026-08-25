/// Compile-time application configuration.
///
/// Values are supplied with `--dart-define` (or `--dart-define-from-file`).
/// They are configuration, not a secret store: values compiled into a mobile
/// application can ultimately be extracted from the application binary.
class Environment {
  const Environment._();

  static const tursoUrl = String.fromEnvironment('TURSO_URL');
  static const tursoAuthToken = String.fromEnvironment('TURSO_AUTH_TOKEN');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static void validate() {
    if (tursoUrl.isEmpty || tursoAuthToken.isEmpty) {
      throw StateError(
        'Missing TURSO_URL or TURSO_AUTH_TOKEN. '
        'Pass both values with --dart-define-from-file.',
      );
    }
  }
}
