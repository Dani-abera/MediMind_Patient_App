import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_consultation_model.dart';

abstract class VideoConsultationRemoteDataSource {
  Future<VideoConsultationModel> getConsultation(String consultationId);
  Future<String> joinConsultation(String consultationId);
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
          await _dio.get('/consultations/$consultationId');
      return VideoConsultationModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<String> joinConsultation(String consultationId) async {
    try {
      final response =
          await _dio.post('/consultations/$consultationId/join');
      return response.data['token'] as String;
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }
}
