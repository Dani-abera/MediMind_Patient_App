import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.toString(),
        type: err.type,
        response: err.response,
      ),
    );
  }

  Exception _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final response = err.response;
    if (response == null) return const NetworkException();

    final data = response.data;
    final message = _extractMessage(data);

    return switch (response.statusCode) {
      400 => ServerException(message: message, code: 400),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      409 => ConflictException(message: message),
      422 => ValidationException(
          message: message,
          errors: _extractValidationErrors(data),
        ),
      _ when (response.statusCode ?? 0) >= 500 =>
        ServerException(message: message, code: response.statusCode),
      _ => ServerException(message: message, code: response.statusCode),
    };
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ?? data['message'] ?? data['title'] ?? 'An error occurred')
          .toString();
    }
    return 'An error occurred';
  }

  Map<String, List<String>> _extractValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return {};
    final errors = data['errors'];
    if (errors is! Map) return {};
    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        (value is List) ? value.map((e) => e.toString()).toList() : [value.toString()],
      ),
    );
  }
}
