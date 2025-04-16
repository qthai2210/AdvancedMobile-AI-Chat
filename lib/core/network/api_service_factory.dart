import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/network/dio_app_logger.dart';
import 'package:dio/dio.dart';

/// Factory for creating service-specific API clients
/// This ensures each service uses its own Dio instance with the correct base URL
class ApiServiceFactory {
  /// Creates a new Dio instance configured for auth API calls
  static Dio createAuthDio() {
    return _createDio(ApiConfig.authBaseUrl);
  }

  /// Creates a new Dio instance configured for knowledge API calls
  static Dio createKnowledgeDio() {
    return _createDio(ApiConfig.knowledgeUrl);
  }

  /// Creates a new Dio instance configured for jarvis API calls
  static Dio createJarvisDio() {
    return _createDio(ApiConfig.jarvisBaseUrl);
  }

  /// Internal helper to create and configure a Dio instance with the given base URL
  static Dio _createDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 180),
      receiveTimeout: const Duration(seconds: 180),
      sendTimeout: const Duration(seconds: 180),
      headers: ApiConfig.defaultHeaders,
    ));

    // Add logging interceptor
    dio.interceptors.add(
      DioAppLogger(
        request: true,
        responseBody: true,
        requestBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
