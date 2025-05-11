import 'package:aichatbot/core/network/dio_app_logger.dart';
import 'package:aichatbot/core/network/token_refresh_interceptor.dart';

import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      //baseUrl: ApiConfig.baseUrl,
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

  /// Creates authorization header with bearer token
  Future<Map<String, String>> createAuthHeader() async {
    // get accesstoken from local storage
    final accessToken = await SecureStorageUtil().getAccessToken();

    if (accessToken == null) {
      throw UnauthorizedException('Access token is null');
    }
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }

  // add auth header to dio instance
  Future<void> addAuthHeader() async {
    final authHeader = await createAuthHeader();
    dio.options.headers.addAll(authHeader);
    AppLogger.e('Dio headers: ${dio.options.headers}');
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
        // 204 means No Content, so response.data might be null or empty
        // For methods that return void, this is fine
        // For methods that expect data, we need to handle this case specially
        try {
          // Try to process the data if it exists
          return onSuccess(response.data);
        } catch (e) {
          // If data is null or empty and causes an error, return null or a default value
          debugPrint('204 response with empty data, returning default value');
          return onSuccess(
              null); // Implementations should handle null data appropriately
        }
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
  dynamic handleError(dynamic error) {
    if (error is DioException) {
      debugPrint('DioException: ${error.type}, Message: ${error.message}');

      // Nếu có response data, trả về nó
      if (error.response?.data != null && error.response?.data is Map) {
        return error.response!.data;
      }

      // Các xử lý lỗi khác
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return NetworkException(
              'Network timeout error. Please check your connection.');
        case DioExceptionType.connectionError:
          return NetworkException(
              'No internet connection. Please check your network.');
        default:
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
    }

    // Nếu error đã là Map lỗi phù hợp, trả về trực tiếp
    if (error is Map && error['code'] != null) {
      return error;
    }

    // Các lỗi khác
    return {
      'code': 'UNEXPECTED_ERROR',
      'error': 'Đã xảy ra lỗi không mong đợi: $error'
    };
  }

  /// Adds a token refresh interceptor to the Dio instance
  void addTokenRefreshInterceptor(TokenRefreshInterceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
