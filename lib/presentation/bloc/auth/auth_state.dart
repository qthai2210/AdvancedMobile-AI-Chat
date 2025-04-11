import 'package:aichatbot/domain/entities/user.dart';

enum AuthStatus { initial, loading, success, failure }

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isLoading => this == AuthStatus.loading;
  bool get isSuccess => this == AuthStatus.success;
  bool get isFailure => this == AuthStatus.failure;
  bool get hasUser => isSuccess;
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final dynamic errorMessage; // Thay đổi từ String? thành dynamic

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    dynamic errorMessage, // Thay đổi từ String? thành dynamic
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
