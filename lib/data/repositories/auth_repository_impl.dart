import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/domain/entities/user.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService authApiService;

  AuthRepositoryImpl({required this.authApiService});

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint(
          'Login request: $email, ${password.isNotEmpty ? "****" : "empty"}');
      final userModel = await authApiService.login(
        email: email,
        password: password,
      );
      return userModel;
    } on DioException catch (e) {
      debugPrint('Login DioException: ${e.message}');

      // Trả về response data gốc nếu có
      if (e.response?.data != null) {
        debugPrint('Login error response data: ${e.response!.data}');
        throw e.response!.data;
      }

      // Nếu không có response data, tạo error message có định dạng thống nhất
      throw {
        'code': 'HTTP_ERROR',
        'error': e.message ?? 'Đã xảy ra lỗi kết nối'
      };
    } catch (e) {
      debugPrint('Login general error: $e');
      throw {'code': 'UNKNOWN_ERROR', 'error': e.toString()};
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint(
          'Register request: $email, ${password.isNotEmpty ? "****" : "empty"}, $name');
      final userModel = await authApiService.register(
        email: email,
        password: password,
        name: name,
      );
      return userModel;
    } on DioException catch (e) {
      debugPrint('Register DioException: ${e.message}');

      // Trả về response data gốc nếu có
      if (e.response?.data != null) {
        debugPrint('Register error response data: ${e.response!.data}');
        throw e.response!.data;
      }

      // Nếu không có response data, tạo error message có định dạng thống nhất
      throw {
        'code': 'HTTP_ERROR',
        'error': e.message ?? 'Đã xảy ra lỗi kết nối'
      };
    } catch (e) {
      debugPrint('Register general error: $e');
      throw {'code': 'UNKNOWN_ERROR', 'error': e.toString()};
    }
  }

  @override
  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      debugPrint('Logout request');
      await authApiService.logout(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      debugPrint('Logout DioException: ${e.message}');

      // Trả về response data gốc nếu có
      if (e.response?.data != null) {
        throw e.response!.data;
      }

      // Nếu không có response data, tạo error message có định dạng thống nhất
      throw {
        'code': 'HTTP_ERROR',
        'error': e.message ?? 'Đã xảy ra lỗi kết nối'
      };
    } catch (e) {
      debugPrint('Logout general error: $e');
      throw {'code': 'UNKNOWN_ERROR', 'error': e.toString()};
    }
  }
}
