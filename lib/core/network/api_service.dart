import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/dio_interceptors.dart';

/// Base API service that handles common functionality for API requests
///
/// This class provides a configured Dio instance with proper interceptors
/// and common methods for API requests.
class ApiService {
  /// The Dio instance used for network requests
  final Dio dio;

  /// Creates a new ApiService instance with optional custom Dio configuration
  ApiService({Dio? dioClient}) : dio = dioClient ?? _createDioInstance();

  /// Creates a configured Dio instance with proper interceptors
  static Dio _createDioInstance() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 180),
      receiveTimeout: const Duration(seconds: 180),
      sendTimeout: const Duration(seconds: 180),
      headers: ApiConfig.defaultHeaders,
    ));

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        error: true,
      ),
    );
    return dio;
  }

  /// Creates authorization header with bearer token
  Map<String, String> createAuthHeader(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Handles API response and converts errors to appropriate exceptions
  T handleResponse<T>(Response response, T Function(dynamic data) onSuccess) {
    switch (response.statusCode) {
      case 200:
        // Handle 200 as success response
        return onSuccess(response.data);
      case 201:
        // Handle 200 and 201 as success responses
        return onSuccess(response.data);

      case 202:
        // Handle 200 and 202 as success responses
        return onSuccess(response.data);
      case 203:
        // Handle 202 and 203 as success responses
        return onSuccess(response.data);

      case 204:
        return onSuccess(response.data);
      case 401:
      case 403:
        throw UnauthorizedException('Authentication error: ${response.data}');
      case 404:
        throw NotFoundException('Resource not found: ${response.data}');
      case 400:
      default:
        throw ServerException(
            'Server error [${response.statusCode}]: ${response.data}');
    }
  }

  /// Handles and formats errors from API calls
  Exception handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return NetworkException(
            'Network timeout error. Please check your connection.');
      }

      if (error.type == DioExceptionType.connectionError) {
        return NetworkException(
            'No internet connection. Please check your network.');
      }

      // Handle error response
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException('Authentication error: $data');
        } else if (statusCode == 404) {
          return NotFoundException('Resource not found: $data');
        }
      }

      return ServerException('Server error: ${error.message}');
    }

    // For non-Dio exceptions, preserve the original type if it's already a custom exception
    if (error is ServerException ||
        error is UnauthorizedException ||
        error is NetworkException) {
      return error;
    }

    // Default error
    return ServerException('Unexpected error: $error');
  }
}
