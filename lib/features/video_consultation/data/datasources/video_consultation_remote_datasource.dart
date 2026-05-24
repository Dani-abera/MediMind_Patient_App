import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_consultation_model.dart';

abstract class VideoConsultationRemoteDataSource {
  Future<VideoConsultationModel> getConsultation(String consultationId);
  Future<String> joinConsultation(String consultationId);
  Future<VideoConsultationModel> getConsultationByAppointmentId(String appointmentId);
}

class VideoConsultationRemoteDataSourceImpl
    implements VideoConsultationRemoteDataSource {
  VideoConsultationRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<VideoConsultationModel> getConsultation(
      String consultationId) async {
    try {
      final response =
          await _dio.get('/video-consultations/$consultationId');
      return VideoConsultationModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    }
  }

  @override
  Future<String> joinConsultation(String consultationId) async {
    try {
      final response =
          await _dio.post('/video-consultations/$consultationId/join');
      final data = response.data as Map<String, dynamic>;
      final yourInfo = data['yourConnectionInfo'] as Map<String, dynamic>? ?? {};
      return yourInfo['connectionId'] as String? ?? '';
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    }
  }

  @override
  Future<VideoConsultationModel> getConsultationByAppointmentId(
      String appointmentId) async {
    try {
      final response = await _dio
          .get('/video-consultations/appointment/$appointmentId');
      return VideoConsultationModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['message'] as String? ?? e.message ?? 'Server error';
    return e.message ?? 'Server error';
  }
}
