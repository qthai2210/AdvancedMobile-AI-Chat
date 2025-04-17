import 'dart:convert';
import 'package:aichatbot/core/errors/auth_exception.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/domain/entities/user.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService authApiService;

  AuthRepositoryImpl({required this.authApiService});

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Login request in repository: $email');
      final user = await authApiService.login(
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      debugPrint('Login error in repository: $e');

      // Xử lý error từ API
      if (e is DioError || e is DioException) {
        // Support both error types
        // Tạo một map chứa thông tin lỗi để dùng với ErrorFormatter
        final Map<String, dynamic> errorData = {};

        // Trích xuất thông tin lỗi từ response
        if (e.response?.data != null) {
          if (e.response!.data is Map<String, dynamic>) {
            // Lấy trực tiếp từ response data
            errorData.addAll(e.response!.data as Map<String, dynamic>);
          } else if (e.response!.data is String) {
            // Thử parse response data nếu là string
            try {
              final parsed = jsonDecode(e.response!.data as String);
              if (parsed is Map<String, dynamic>) {
                errorData.addAll(parsed);
              }
            } catch (_) {
              // Bỏ qua lỗi parse JSON
            }
          }
        }

        // Thêm thông tin lỗi mặc định nếu không có trong response
        if (!errorData.containsKey('code')) {
          errorData['code'] = 'UNKNOWN_ERROR';
        }

        if (!errorData.containsKey('error')) {
          errorData['error'] = e.message ?? 'Đăng nhập thất bại';
        }

        // In log để debug
        debugPrint('Extracted error data: $errorData');

        // Ném lỗi với dữ liệu đã xử lý để ErrorFormatter có thể sử dụng
        throw AuthException(
            message: ErrorFormatter.formatAuthError(errorData),
            code: errorData['code'] ?? 'UNKNOWN_ERROR',
            statusCode: e.response?.statusCode);
      } else if (e is Map<String, dynamic>) {
        // Handle the case where the error is already a Map
        throw AuthException(
            message: ErrorFormatter.formatAuthError(e),
            code: e['code'] ?? 'UNKNOWN_ERROR');
      }

      // Trường hợp lỗi khác không phải DioError
      throw AuthException(
        message: 'Đăng nhập thất bại. Vui lòng thử lại sau.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Register request: $email, $name');
      final user = await authApiService.register(
        name: name,
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      // Xử lý error từ API và chuyển đổi thành AuthException
      if (e is DioError) {
        debugPrint('Register error in repository: $e');

        final errorException = _handleDioError(e);
        throw errorException;
      }

      // Trường hợp lỗi khác
      throw AuthException(
        message: 'Đăng ký thất bại. Vui lòng thử lại sau.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await authApiService.logout(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      debugPrint('Logout error in repository: $e');
      if (e is DioError) {
        final errorException = _handleDioError(e);
        throw errorException;
      }

      throw AuthException(
        message: 'Đăng xuất thất bại. Vui lòng thử lại sau.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  AuthException _handleDioError(DioError error) {
    // Mặc định thông báo lỗi
    String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
    String errorCode = 'UNKNOWN_ERROR';

    try {
      // Kiểm tra response có dữ liệu không
      if (error.response != null && error.response!.data != null) {
        final responseData = error.response!.data;

        // Parse dữ liệu từ response
        if (responseData is Map<String, dynamic>) {
          // Lấy code lỗi từ API
          if (responseData.containsKey('code')) {
            errorCode = responseData['code'];
          }

          // Lấy thông báo lỗi từ API
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }

          // Format message dựa trên error code
          errorMessage = ErrorFormatter.formatAuthError(responseData);
        }
      }
    } catch (e) {
      debugPrint('Error parsing API error response: $e');
    }

    return AuthException(
      message: errorMessage,
      code: errorCode,
      statusCode: error.response?.statusCode,
    );
  }
}
