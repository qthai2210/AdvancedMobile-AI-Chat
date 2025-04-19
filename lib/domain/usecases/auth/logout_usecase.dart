import 'package:aichatbot/domain/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<void> call({
    required String accessToken,
    String? refreshToken,
  }) async {
    return await repository.logout(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
