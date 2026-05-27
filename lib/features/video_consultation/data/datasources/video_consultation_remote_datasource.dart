import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_consultation_model.dart';

typedef JoinResult = ({
  String token,
  String roomId,
  String appId,
  String userType,
  String rtmToken,
  String rtmUserId,
});

abstract class VideoConsultationRemoteDataSource {
  Future<VideoConsultationModel> getConsultation(String consultationId);
  Future<JoinResult> joinConsultation(String consultationId);
  Future<VideoConsultationModel> getConsultationByAppointmentId(String appointmentId);
  Future<void> sendMessage(String consultationId, String content);
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
  Future<JoinResult> joinConsultation(String consultationId) async {
    try {
      final response =
          await _dio.post('/video-consultations/$consultationId/join');
      final data = response.data as Map<String, dynamic>;
      final yourInfo = data['yourConnectionInfo'] as Map<String, dynamic>? ?? {};
      return (
        token: (data['agoraToken'] as String? ?? '').replaceAll(RegExp(r'\s+'), ''),
        roomId: data['roomId'] as String? ?? consultationId,
        appId: (data['agoraAppId'] as String? ?? '').trim(),
        userType: yourInfo['userType'] as String? ?? 'patient',
        rtmToken: (data['agoraRtmToken'] as String? ?? '').replaceAll(RegExp(r'\s+'), ''),
        rtmUserId: (data['agoraRtmUserId'] as String? ?? '').trim(),
      );
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

  @override
  Future<void> sendMessage(String consultationId, String content) async {
    try {
      await _dio.post(
        '/video-consultations/$consultationId/messages',
        data: {'content': content},
      );
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
