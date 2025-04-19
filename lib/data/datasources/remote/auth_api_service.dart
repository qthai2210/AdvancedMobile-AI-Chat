import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';

import 'package:aichatbot/data/models/auth/user_model.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthApiService {
  // Use a dedicated Dio instance for auth operations
  final Dio _dio;
  final ApiService _apiService;

  // Constructor - initialize with a dedicated auth Dio instance
  AuthApiService()
      : _dio = ApiServiceFactory.createAuthDio(),
        _apiService = sl.get<ApiService>() {
    AppLogger.w('AuthApiService initialized with dedicated Dio instance');
    AppLogger.w('Base URL: ${_dio.options.baseUrl}');
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    const endpoint = '/auth/password/sign-in';
    final body = {
      'email': email,
      'password': password,
    };
    try {
      debugPrint('Sending login request to $endpoint with email: $email');

      // Use the dedicated Dio instance for this request
      final response = await _dio.post(
        endpoint,
        data: body,
      );

      debugPrint('Login response status: ${response.statusCode}');

      // Kiểm tra status code trước khi xử lý response
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Thành công
        return _apiService.handleResponse<UserModel>(
          response,
          (data) {
            if (data['access_token'] == null ||
                data['refresh_token'] == null ||
                data['user_id'] == null) {
              throw {
                'code': 'INVALID_RESPONSE_FORMAT',
                'error': 'Phản hồi từ máy chủ không hợp lệ'
              };
            }
            // Lưu access token và refresh token vào secure storage
            AppLogger.i(
                'Login successful, saving tokens to secure storage: ${data['access_token']}, ${data['refresh_token']}');
            final secureStorageUtil = sl.get<SecureStorageUtil>();
            secureStorageUtil.writeSecureData(
                accessToken: data['access_token'],
                refreshToken: data['refresh_token']);
            _apiService.addAuthHeader();
            return UserModel.fromJson(data, email);
          },
        );
      } else {
        // Xử lý các trường hợp lỗi
        debugPrint('Login error response: ${response.data}');

        // Trả về dữ liệu lỗi từ API nếu có
        if (response.data != null && response.data is Map) {
          throw response.data;
        }

        // Fallback cho các mã lỗi HTTP khác
        throw {
          'code': 'HTTP_ERROR',
          'error': 'Lỗi máy chủ: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');

      // Nếu đã là Map lỗi, trả về trực tiếp
      if (e is Map && e['code'] != null) {
        rethrow;
      }

      // Xử lý DioException
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          throw e.response!.data;
        }

        // Xử lý các loại lỗi kết nối
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw {
            'code': 'CONNECTION_TIMEOUT',
            'error': 'Kết nối tới máy chủ quá thời gian, vui lòng thử lại sau'
          };
        }

        if (e.type == DioExceptionType.connectionError) {
          throw {
            'code': 'CONNECTION_ERROR',
            'error':
                'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng'
          };
        }
      }

      // Các lỗi khác
      throw {
        'code': 'UNEXPECTED_ERROR',
        'error': 'Đã xảy ra lỗi không mong đợi: $e'
      };
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Use dedicated Dio instance
      final response = await _dio.post(
        '/auth/password/sign-up',
        data: {
          'email': email,
          'password': password,
          'verification_callback_url':
              'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess',
        },
      );

      // Xử lý response
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Success - Create user model from response
        final userModel = UserModel.fromJson(
          response.data,
          email,
        );

        // Navigate to login page after successful registration
        // Note: This should be handled in the UI layer (bloc/cubit), not in the API service
        // The API service should just return the result and let the UI handle navigation
        return userModel;
      } else {
        debugPrint(
            'Register response error: ${response.statusCode}, ${response.data}');

        // Trả về dữ liệu lỗi từ API nếu có
        if (response.data != null) {
          throw response.data;
        }

        // Fallback nếu không có dữ liệu lỗi
        throw {
          'code': 'HTTP_ERROR',
          'error': 'Lỗi máy chủ: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      debugPrint('Register DioException: ${e.type}, ${e.message}');

      // Nếu có response data, trả về nó
      if (e.response?.data != null) {
        throw e.response!.data;
      }

      // Xử lý các lỗi kết nối
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw {
          'code': 'CONNECTION_TIMEOUT',
          'error': 'Kết nối tới máy chủ quá thời gian, vui lòng thử lại sau'
        };
      }

      if (e.type == DioExceptionType.connectionError) {
        throw {
          'code': 'CONNECTION_ERROR',
          'error':
              'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng'
        };
      }

      // Lỗi chung
      throw {
        'code': 'HTTP_ERROR',
        'error': e.message ?? 'Đã xảy ra lỗi khi kết nối đến máy chủ'
      };
    } catch (e) {
      debugPrint('Register unexpected error: $e');

      // Nếu đã là Map lỗi, giữ nguyên
      if (e is Map && e['code'] != null) {
        rethrow;
      }

      // Các lỗi khác
      throw {
        'code': 'UNEXPECTED_ERROR',
        'error': 'Đã xảy ra lỗi không mong đợi: $e'
      };
    }
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    const endpoint = '/auth/sessions/current';

    // Create options with custom headers for this request
    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    if (refreshToken != null) {
      headers['X-Stack-Refresh-Token'] = refreshToken;
    }

    try {
      // Use dedicated Dio instance
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
        data: {},
      );

      _apiService.handleResponse<void>(
        response,
        (_) {}, // No data to return for successful logout
      );
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }

  /// Refreshes the access token using the refresh token
  ///
  /// Returns the new access token if successful
  Future<String?> refreshToken(String refreshToken) async {
    try {
      AppLogger.i('Attempting to refresh token');

      // We don't need to save/restore base URLs because we're using a dedicated Dio instance
      // with the correct auth base URL already set

      final response = await _dio.post(
        '/auth/sessions/current/refresh',
        options: Options(
          headers: {
            'X-Stack-Refresh-Token': refreshToken,
          },
          contentType: 'application/json',
        ),
        data: {},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];
        AppLogger.i('Token refresh successful, obtained new access token');
        return newAccessToken;
      } else {
        AppLogger.e('Token refresh failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error refreshing token: $e');
      return null;
    }
  }

  // Method to get the Dio instance for TokenRefreshInterceptor to use
  Dio get dio => _dio;
}
