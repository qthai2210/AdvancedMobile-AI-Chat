// Tạo file mới: lib/core/errors/auth_exceptions.dart
class AuthException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  AuthException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AuthException: $message (Code: $code, Status: $statusCode)';
  }
}
