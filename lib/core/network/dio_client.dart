import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logger_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio createDio(SecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LoggerInterceptor(),
      AuthInterceptor(secureStorage: secureStorage, dio: dio),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
