import 'package:aichatbot/domain/entities/user.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.login(
      email: email,
      password: password,
    );
  }
}
