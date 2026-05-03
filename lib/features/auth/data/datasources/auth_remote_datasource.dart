import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/otp_request_model.dart';
import '../models/register_request_model.dart';


abstract class AuthRemoteDataSource {
  Future<String> registerPatient(RegisterRequestModel request);
  Future<void> requestOtp(OtpRequestModel request);
  Future<AuthTokensModel> verifyOtp(
    OtpVerifyRequestModel request,
  );
  Future<AuthTokensModel> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<String> registerPatient(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        '/auth/patient/register',
        data: request.toJson(),
      );
      return response.data['patientId'] as String;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> requestOtp(OtpRequestModel request) async {
    try {
      await _dio.post('/auth/patient/request-otp', data: request.toJson());
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AuthTokensModel> verifyOtp(
    OtpVerifyRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/patient/verify-otp',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return AuthTokensModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      return AuthTokensModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractMessage(e);

    return switch (statusCode) {
      400 => ServerException(message: message, code: 400),
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      409 => ConflictException(message: message),
      null => NetworkException(message: message),
      _ => ServerException(message: message, code: statusCode),
    };
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['error'] as String? ??
            e.message ??
            'An error occurred';
      }
    } catch (_) {}
    return e.message ?? 'An error occurred';
  }
}
