class AppSecrets {
  AppSecrets._();

  static const String _demoSecret = String.fromEnvironment('DEMO_SECRET', defaultValue: '');

  static void ensureLoaded() {
    if (_demoSecret.isEmpty) {
      throw StateError(
        'DEMO_SECRET was not provided. Supply it via --dart-define or environment variable before running.',
      );
    }
  }

  static String get demoSecret {
    ensureLoaded();
    return _demoSecret;
  }
}
