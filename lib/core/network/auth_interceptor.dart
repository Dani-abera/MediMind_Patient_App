import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class AuthEventBus {
  AuthEventBus._();
  static final AuthEventBus instance = AuthEventBus._();

  final _controller = StreamController<AuthEvent>.broadcast();
  Stream<AuthEvent> get events => _controller.stream;

  void emit(AuthEvent event) => _controller.add(event);
}

enum AuthEvent { logout }

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.secureStorage, required this.dio});

  final SecureStorage secureStorage;
  final Dio dio;

  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Guard: if the refresh endpoint itself returned 401, don't retry (prevents deadlock)
    if (err.requestOptions.path == ApiConstants.authRefreshEndpoint) {
      _logout();
      handler.next(err);
      return;
    }

    // Prevent concurrent refreshes
    if (_refreshCompleter != null) {
      final success = await _refreshCompleter!.future;
      if (success) {
        final token = await secureStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } else {
        handler.next(err);
      }
      return;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final success = await _refreshToken();
      _refreshCompleter!.complete(success);
      if (success) {
        final token = await secureStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } else {
        handler.next(err);
      }
    } catch (_) {
      _refreshCompleter!.complete(false);
      handler.next(err);
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logout();
        return false;
      }
      final response = await dio.post(
        ApiConstants.authRefreshEndpoint,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      await secureStorage.saveAccessToken(data['accessToken'] as String);
      if (data['refreshToken'] != null) {
        await secureStorage.saveRefreshToken(data['refreshToken'] as String);
      }
      return true;
    } catch (_) {
      _logout();
      return false;
    }
  }

  void _logout() {
    secureStorage.clearAll();
    AuthEventBus.instance.emit(AuthEvent.logout);
  }
}
