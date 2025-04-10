import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/domain/entities/user.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/auth_failure.dart';
import 'package:flutter/material.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService authApiService;

  AuthRepositoryImpl({required this.authApiService});

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Login request: $email, $password');
      final userModel = await authApiService.login(
        email: email,
        password: password,
      );
      return userModel;
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } on InvalidResponseFormatException {
      throw AuthFailure('Invalid response format');
    } catch (e) {
      throw AuthFailure('Unexpected error: $e');
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await authApiService.register(
        email: email,
        password: password,
        name: name,
      );
      return userModel;
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } on InvalidResponseFormatException {
      throw AuthFailure('Invalid response format');
    } catch (e) {
      throw AuthFailure('Unexpected error: $e');
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
    } on ServerException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Unexpected error: $e');
    }
  }
}
