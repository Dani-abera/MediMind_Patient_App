import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/appointment_detail_model.dart';

abstract class AppointmentsRemoteDataSource {
  Future<AppointmentDetailModel> createAppointment({
    required String doctorId,
    required String centerId,
    required DateTime appointmentTime,
    required String slotId,
    String? reasonForVisit,
    String? symptoms,
  });

  Future<List<AppointmentDetailModel>> getUpcomingAppointments();
  Future<List<AppointmentDetailModel>> getPastAppointments({
    int page = 1,
    int pageSize = 20,
  });
  Future<AppointmentDetailModel> getAppointmentDetail(String appointmentId);
  Future<void> cancelAppointment(String appointmentId);
}

class AppointmentsRemoteDataSourceImpl
    implements AppointmentsRemoteDataSource {
  const AppointmentsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<AppointmentDetailModel> createAppointment({
    required String doctorId,
    required String centerId,
    required DateTime appointmentTime,
    required String slotId,
    String? reasonForVisit,
    String? symptoms,
  }) async {
    try {
      final response = await _dio.post(
        '/appointments',
        data: {
          'doctorId': doctorId,
          'centerId': centerId,
          'appointmentTime': appointmentTime.toIso8601String(),
          'slotId': slotId,
          if (reasonForVisit != null) 'reasonForVisit': reasonForVisit,
          if (symptoms != null) 'symptoms': symptoms,
        },
      );
      return AppointmentDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<AppointmentDetailModel>> getUpcomingAppointments() async {
    try {
      final response = await _dio.get('/appointments/upcoming');
      final items = response.data as List<dynamic>;
      return items
          .map((e) => AppointmentDetailModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<AppointmentDetailModel>> getPastAppointments({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/appointments/past',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final items =
          (response.data['items'] ?? response.data) as List<dynamic>;
      return items
          .map((e) => AppointmentDetailModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<AppointmentDetailModel> getAppointmentDetail(
      String appointmentId) async {
    try {
      final response =
          await _dio.get('/appointments/$appointmentId');
      return AppointmentDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/cancel');
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }
}
