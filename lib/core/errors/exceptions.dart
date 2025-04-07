class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache error']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Network error']);

  @override
  String toString() => message;
}

class InvalidResponseFormatException implements Exception {
  final String message;

  InvalidResponseFormatException([this.message = 'Invalid response format']);

  @override
  String toString() => message;
}
