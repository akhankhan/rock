class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String apiUrl = String.fromEnvironment('API_URL', 
    defaultValue: 'https://dev-api.example.com');
} 