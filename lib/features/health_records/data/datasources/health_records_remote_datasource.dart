import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/health_record_model.dart';
import '../models/health_trend_model.dart';

abstract class HealthRecordsRemoteDataSource {
  Future<HealthRecordModel> logVitals(Map<String, dynamic> body);
  Future<HealthRecordModel> updateRecord(
      String id, Map<String, dynamic> body);
  Future<List<HealthRecordModel>> getHealthRecords({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });
  Future<HealthRecordModel?> getLatestRecord();
  Future<void> deleteRecord(String id);
  Future<HealthTrendsDataModel> getTrends({int days = 30});
  Future<int> getRecordCount();
}

class HealthRecordsRemoteDataSourceImpl
    implements HealthRecordsRemoteDataSource {
  const HealthRecordsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<HealthRecordModel> logVitals(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/health-records', data: body);
      return HealthRecordModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<HealthRecordModel> updateRecord(
      String id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put('/health-records/$id', data: body);
      return HealthRecordModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<List<HealthRecordModel>> getHealthRecords({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/health-records',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      final items =
          (response.data['items'] ?? response.data) as List<dynamic>;
      return items
          .map((e) =>
              HealthRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<HealthRecordModel?> getLatestRecord() async {
    try {
      final response = await _dio.get('/health-records/latest');
      if (response.data == null) return null;
      return HealthRecordModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapDio(e);
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      await _dio.delete('/health-records/$id');
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<HealthTrendsDataModel> getTrends({int days = 30}) async {
    try {
      final response = await _dio.get(
        '/health-records/trends',
        queryParameters: {'days': days},
      );
      return HealthTrendsDataModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<int> getRecordCount() async {
    try {
      final response = await _dio.get('/health-records/count');
      return response.data['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Exception _mapDio(DioException e) => e.error is Exception
      ? e.error as Exception
      : ServerException(message: e.message ?? 'Server error');
}
