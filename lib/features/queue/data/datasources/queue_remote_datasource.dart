import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/queue_status_model.dart';

abstract class QueueRemoteDataSource {
  Future<QueueStatusModel> getQueueStatus(String appointmentId);
  Future<void> cancelQueuePosition(String appointmentId);
}

class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  QueueRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<QueueStatusModel> getQueueStatus(String appointmentId) async {
    try {
      final response =
          await _dio.get('/queue/status/$appointmentId');
      return QueueStatusModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<void> cancelQueuePosition(String appointmentId) async {
    try {
      await _dio.post('/queue/cancel/$appointmentId');
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }
}
