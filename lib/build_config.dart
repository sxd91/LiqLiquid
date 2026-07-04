abstract final class BuildConfig {
  static const int versionCode = int.fromEnvironment(
    'liq.code',
    defaultValue: 1,
  );
  static const String versionName = String.fromEnvironment(
    'liq.name',
    defaultValue: 'SNAPSHOT',
  );

  static const int buildTime = int.fromEnvironment('liq.time');
  static const String commitHash = String.fromEnvironment(
    'liq.hash',
    defaultValue: 'N/A',
  );
}

