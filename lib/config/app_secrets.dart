class AppSecrets {
  AppSecrets._();

  static const String _demoSecret = String.fromEnvironment('DEMO_SECRET', defaultValue: '');

  static void ensureLoaded() {
    // Made optional to prevent app crashes when secret is not provided
    // Log warning instead of throwing exception
    if (_demoSecret.isEmpty) {
      // ignore: avoid_print
      print('Warning: DEMO_SECRET was not provided. Some features may be limited.');
    }
  }

  static String get demoSecret {
    return _demoSecret;
  }
}
