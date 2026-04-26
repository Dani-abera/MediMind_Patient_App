import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/appointment_model.dart';
import '../models/health_prediction_model.dart';
import '../models/health_record_model.dart';
import '../models/healthcare_center_model.dart';

abstract class HomeRemoteDataSource {
  Future<AppointmentModel?> getUpcomingAppointment();
  Future<HealthRecordModel?> getLatestHealthRecord();
  Future<HealthPredictionModel?> getLatestPrediction();
  Future<List<HealthcareCenterModel>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  Future<int> getUnreadNotificationCount();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<AppointmentModel?> getUpcomingAppointment() async {
    try {
      final res = await _dio.get('/appointments/upcoming');
      final data = res.data;
      if (data == null) return null;
      if (data is List && data.isEmpty) return null;
      final json = data is List
          ? data.first as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return AppointmentModel.fromJson(json);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    }
  }

  @override
  Future<HealthRecordModel?> getLatestHealthRecord() async {
    try {
      final res = await _dio.get('/health-records/latest');
      if (res.data == null) return null;
      return HealthRecordModel.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    }
  }

  @override
  Future<HealthPredictionModel?> getLatestPrediction() async {
    try {
      final res = await _dio.get('/health-predictions/latest');
      if (res.data == null) return null;
      return HealthPredictionModel.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    }
  }

  @override
  Future<List<HealthcareCenterModel>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      final res = await _dio.get(
        '/healthcare-centers/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );
      final list = res.data as List? ?? [];
      return list
          .map((e) =>
              HealthcareCenterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      final res = await _dio.get('/notifications/unread-count');
      return (res.data['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Exception _map(DioException e) {
    final code = e.response?.statusCode;
    final msg = _extractMsg(e);
    return switch (code) {
      401 => UnauthorizedException(message: msg),
      null => NetworkException(message: msg),
      _ => ServerException(message: msg, code: code),
    };
  }

  String _extractMsg(DioException e) {
    try {
      final d = e.response?.data;
      if (d is Map<String, dynamic>) {
        return d['message'] as String? ?? e.message ?? 'Error';
      }
    } catch (_) {}
    return e.message ?? 'Error';
  }
}
