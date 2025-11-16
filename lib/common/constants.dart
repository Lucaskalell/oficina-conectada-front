class ApiConstants {
  static const bool isLocal = true;

  static const String _localBaseUrl = 'http://localhost:8080';

  static const String _testBaseUrl = 'https://api-teste-quando-subir';

  static String get baseUrl {
    return isLocal ? _localBaseUrl : _testBaseUrl;
  }
}
