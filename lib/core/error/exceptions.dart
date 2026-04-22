class ServerException implements Exception {
  const ServerException({required this.message, this.code});
  final String message;
  final int? code;
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});
  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Unauthorized'});
  final String message;
}

class ForbiddenException implements Exception {
  const ForbiddenException({this.message = 'Access denied'});
  final String message;
}

class NotFoundException implements Exception {
  const NotFoundException({this.message = 'Resource not found'});
  final String message;
}

class ConflictException implements Exception {
  const ConflictException({required this.message});
  final String message;
}

class ValidationException implements Exception {
  const ValidationException({
    required this.message,
    required this.errors,
  });
  final String message;
  final Map<String, List<String>> errors;
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error'});
  final String message;
}
