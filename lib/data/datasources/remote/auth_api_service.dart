import 'package:dio/dio.dart';
import 'package:aichatbot/data/models/auth/user_model.dart';
import 'package:aichatbot/domain/entities/user.dart'; // Ensure User is imported

class AuthApiService {
  final Dio dio;

  AuthApiService({required this.dio});

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/password/sign-in',
        data: {'email': email, 'password': password},
      );

      return UserModel.fromJson(
        response.data,
        email,
        name: response.data['name'],
      );
    } catch (e) {
      // Không bọc trong ServerException, để repository xử lý trực tiếp
      rethrow;
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/password/sign-up',
        data: {'email': email, 'password': password, 'name': name},
      );

      return UserModel.fromJson(
        response.data,
        email,
        name: response.data['name'],
      );
    } catch (e) {
      // Không bọc trong ServerException, để repository xử lý trực tiếp
      rethrow;
    }
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await dio.post(
        '/api/v1/auth/logout',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } catch (e) {
      // Không bọc trong ServerException, để repository xử lý trực tiếp
      rethrow;
    }
  }
}
