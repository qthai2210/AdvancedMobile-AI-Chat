abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class PromptFailure extends Failure {
  PromptFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  PermissionFailure(String message) : super(message);
}

// Các failure class khác có thể thêm sau này
