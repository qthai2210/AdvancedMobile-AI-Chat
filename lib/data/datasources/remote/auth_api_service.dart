import 'package:aichatbot/core/di/injection_container.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/models/auth/user_model.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthApiService {
  final ApiService _apiService = sl.get<ApiService>();
  AuthApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = ApiConfig.authBaseUrl;
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

      final response = await _apiService.dio.post(
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
      final response = await _apiService.dio.post(
        ApiConfig.authBaseUrl + '/auth/password/sign-up',
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
    final headers = _apiService.createAuthHeader(accessToken);

    if (refreshToken != null) {
      headers['X-Stack-Refresh-Token'] = refreshToken;
    }

    try {
      final response = await _apiService.dio.delete(
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
}
