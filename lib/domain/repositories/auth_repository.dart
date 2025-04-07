import 'package:aichatbot/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  });
}
