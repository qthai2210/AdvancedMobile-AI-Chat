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
      // Truyền thẳng lỗi lên không chuyển đổi
      rethrow;
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
      debugPrint('Register error in repository: $e');
      // Truyền thẳng lỗi lên không chuyển đổi, tương tự như login
      rethrow;
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
      rethrow;
    }
  }
}
