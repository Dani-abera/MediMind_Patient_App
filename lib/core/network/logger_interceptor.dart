import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoggerInterceptor extends Interceptor {
  LoggerInterceptor()
    : _logger = PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        maxWidth: 90,
        enabled: kDebugMode,
        error: true,
        compact: true,
        filter: (options, args) {
          // Never log auth headers
          if (options.headers.containsKey('Authorization')) {
            options.headers.remove('Authorization');
          }
          // Don't log response body for auth endpoints
          if (options.path.contains('/auth/')) {
            return false;
          }
          return true;
        },
      );

  final PrettyDioLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.onRequest(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.onError(err, handler);
    } else {
      handler.next(err);
    }
  }
}
