import 'package:aichatbot/domain/entities/user.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
