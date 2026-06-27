class ApiConstants {
  static const bool _local = true;

  static const String _urlLocal = 'http://localhost:8080';
  static const String _urlEmuladorAndroid = 'http://10.0.2.2:8080';

  static String get baseUrl => _local ? _urlLocal : _urlEmuladorAndroid;
}
