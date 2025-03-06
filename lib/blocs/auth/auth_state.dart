enum AuthStatus { initial, loading, success, failure }

class User {
  final String id;
  final String email;
  final String name;
  final String? directNavigationPath; // New field for direct navigation

  User({
    required this.id,
    required this.email,
    required this.name,
    this.directNavigationPath,
  });
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
