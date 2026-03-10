/// Environment configuration for different deployment targets
class Environment {
  // API base URL - can be overridden with --dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  // Environment name
  static const String environmentName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Debug mode
  static const bool isDebug = String.fromEnvironment(
    'DEBUG',
    defaultValue: 'true',
  ) == 'true';

  // Helper methods
  static bool get isDevelopment => environmentName == 'development';
  static bool get isProduction => environmentName == 'production';
  static bool get isStaging => environmentName == 'staging';

  // Get appropriate API URL based on platform
  static String getApiUrl() {
    // If explicitly set via dart-define, use that
    if (apiBaseUrl != 'http://localhost:8080/api/v1') {
      return apiBaseUrl;
    }

    // Default for different environments
    // Android emulator uses 10.0.2.2 for localhost
    // iOS simulator uses localhost
    // Physical devices need your computer's IP or production URL
    return apiBaseUrl;
  }
}
