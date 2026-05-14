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
          await _dio.get('/api/v1/video-consultations/$consultationId');
      return VideoConsultationModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<String> joinConsultation(String consultationId) async {
    try {
      final response =
          await _dio.post('/api/v1/video-consultations/$consultationId/join');
      final data = response.data['data'] as Map<String, dynamic>;
      // Returns the caller's own SignalR connectionId from ConsultationJoinDto
      final yourInfo = data['yourConnectionInfo'] as Map<String, dynamic>? ?? {};
      return yourInfo['connectionId'] as String? ?? '';
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<VideoConsultationModel> getConsultationByAppointmentId(
      String appointmentId) async {
    try {
      final response = await _dio
          .get('/api/v1/video-consultations/appointment/$appointmentId');
      return VideoConsultationModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }
}
