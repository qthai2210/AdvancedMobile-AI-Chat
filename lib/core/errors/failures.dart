abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server error']) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache error']) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error']) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure([String message = 'Authentication error']) : super(message);
}

class PromptFailure extends Failure {
  PromptFailure([String message = 'Prompt operation failed']) : super(message);
}
