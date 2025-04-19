import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';

/// Interceptor to handle 401 Unauthorized errors by refreshing tokens and retrying requests
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthApiService authApiService;
  final SecureStorageUtil secureStorage;

  // Flag to prevent infinite loop of refresh token attempts
  bool _isRefreshing = false;

  // Queue of requests to retry after token refresh
  final _pendingRequests = <RequestOptions>[];

  TokenRefreshInterceptor({
    required this.dio,
    required this.authApiService,
    required this.secureStorage,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if ((err.response?.statusCode == 401 || err.response?.statusCode == 404) &&
        !_isRefreshing) {
      AppLogger.i(
          'Caught ${err.response?.statusCode} error, attempting to refresh token and retry request');

      // Get original request
      final RequestOptions options = err.requestOptions;

      // Add to pending if we're already refreshing
      if (_isRefreshing) {
        _pendingRequests.add(options);
        return;
      }

      _isRefreshing = true;

      try {
        // Get the refresh token from secure storage
        final refreshToken = await secureStorage.getRefreshToken();
        if (refreshToken == null) {
          AppLogger.e('Refresh token is null, cannot refresh access token');
          return handler.next(err);
        }
        AppLogger.i('Refreshing token with refresh token: $refreshToken');
        // Get new access token using auth service
        final newAccessToken = await authApiService.refreshToken(refreshToken);
        if (newAccessToken == null) {
          AppLogger.e('Failed to refresh token, new access token is null');
          return handler.next(err);
        }
        AppLogger.i('New access token obtained: $newAccessToken');
        // Save the new token to secure storage
        await secureStorage.saveAccessToken(newAccessToken);
        AppLogger.i('New access token obtained: $newAccessToken');
        // Retry original request with new token
        final response =
            await _retryRequest(options: options, accessToken: newAccessToken);

        // Process any pending requests with the new token
        for (final pendingRequest in _pendingRequests) {
          await _retryRequest(
              options: pendingRequest, accessToken: newAccessToken);
        }

        _pendingRequests.clear();
        _isRefreshing = false;

        // Return the successful response
        return handler.resolve(response);
      } catch (e) {
        debugPrint('Error during token refresh and retry: $e');
      }

      _isRefreshing = false;
      _pendingRequests.clear();
    }

    // If we couldn't refresh the token or it's not a 401 error, continue with the error
    return handler.next(err);
  }

  /// Retry a request with a new access token
  Future<Response> _retryRequest({
    required RequestOptions options,
    required String accessToken,
  }) async {
    // Update the authorization header with the new token
    final headers = Map<String, dynamic>.from(options.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    // Create new request options with the updated headers
    final newOptions = Options(
      method: options.method,
      headers: headers,
      contentType: options.contentType,
      responseType: options.responseType,
      validateStatus: options.validateStatus,
    );

    debugPrint('Retrying request to ${options.path} with new token');

    // Make a new request with the original parameters and new token
    return await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }
}
