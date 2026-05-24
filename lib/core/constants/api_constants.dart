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
}
