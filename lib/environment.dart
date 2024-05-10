class Environment {
  static const String devBackend = "development_backend";
  static const String prodBackend = "production_backend";
  static const String typhonVersion = "0.0.1";

  static String _state = devBackend;
  static String getEnvironment() {
    return _state;
  }

  static void setEnvironment(String state) {
    _state = state;
  }
}
