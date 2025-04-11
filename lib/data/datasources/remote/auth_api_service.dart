import 'package:aichatbot/core/di/injection_container.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/models/auth/user_model.dart';
import 'package:aichatbot/core/network/api_service.dart';

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
      final response = await _apiService.dio.post(
        endpoint,
        data: body,
      );
      return _apiService.handleResponse<UserModel>(
        response,
        (data) {
          if (data['access_token'] == null ||
              data['refresh_token'] == null ||
              data['user_id'] == null) {
            throw InvalidResponseFormatException();
          }
          return UserModel.fromJson(data, email);
        },
      );
    } catch (e) {
      print('Login error: $e');
      print('Login error response: ${e.toString()}');
      if (e is InvalidResponseFormatException) {
        rethrow;
      }
      throw _apiService.handleError(e);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    const endpoint = '/auth/password/sign-up';

    final body = {
      'email': email,
      'password': password,
      'verification_callback_url': 'aichatbot://verify',
    };

    try {
      final response = await _apiService.dio.post(
        endpoint,
        data: body,
      );

      return _apiService.handleResponse<UserModel>(
        response,
        (data) {
          if (data['access_token'] == null ||
              data['refresh_token'] == null ||
              data['user_id'] == null) {
            throw InvalidResponseFormatException();
          }
          return UserModel.fromJson(data, email, name: name);
        },
      );
    } catch (e) {
      if (e is InvalidResponseFormatException) {
        rethrow;
      }
      throw _apiService.handleError(e);
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
