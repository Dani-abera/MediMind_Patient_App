import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.medimind.et/api/v1';

  static String get signalRBaseUrl =>
      dotenv.env['SIGNALR_BASE_URL'] ?? 'https://api.medimind.et';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authRefreshEndpoint = '/auth/refresh-token';

  //static final String? chapaPublicKey = dotenv.env['CHAPA_PUBLIC_KEY'];
  static String get chapaPublicKey => dotenv.env['CHAPA_PUBLIC_KEY'] ?? '';

  // Converts a relative API image path (e.g. /uploads/...) to an absolute URL.
  // Full URLs are returned unchanged.
  static String resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final host = signalRBaseUrl.replaceFirst(RegExp(r'/$'), '');
    return '$host$url';
  }
}
