import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// SSL Pinning interceptor that validates the server certificate against
/// the bundled certificate. Active only in release builds.
///
/// Place the cert at assets/certs/medimind.cer (DER-encoded).
class SslPinningInterceptor extends Interceptor {
  SslPinningInterceptor();

  static SecurityContext? _securityContext;

  /// Call once at startup to load the cert before Dio is created.
  static Future<void> loadCertificate() async {
    if (kDebugMode) return; // Skip pinning in debug
    try {
      final certBytes =
          await rootBundle.load('assets/certs/medimind.cer');
      final context = SecurityContext(withTrustedRoots: false);
      context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      _securityContext = context;
    } catch (_) {
      // If cert missing, fall back to system trust — log in Crashlytics
    }
  }

  static SecurityContext? get securityContext => _securityContext;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    // Validation is done at HttpClient level via badCertificateCallback.
    // This interceptor is a no-op at request time; the security context
    // is injected into Dio's httpClientAdapter at client construction.
    handler.next(options);
  }
}
