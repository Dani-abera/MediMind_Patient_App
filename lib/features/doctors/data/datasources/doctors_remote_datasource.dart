import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../appointments/domain/entities/time_slot.dart';
import '../models/doctor_model.dart';

abstract class DoctorsRemoteDataSource {
  Future<List<DoctorModel>> getCenterDoctors(
    String centerId, {
    String? specialization,
  });

  Future<List<DoctorModel>> getDoctors({
    String? centerId,
    String? specialization,
    String? name,
  });

  Future<DoctorModel> getDoctorDetail(String doctorId);

  Future<List<TimeSlot>> getDoctorAvailability({
    required String doctorId,
    required String centerId,
    required DateTime date,
  });

  Future<List<DateTime>> getDoctorAvailableDates({
    required String doctorId,
    required String centerId,
    int daysAhead = 30,
  });
}

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  const DoctorsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<DoctorModel>> getCenterDoctors(
    String centerId, {
    String? specialization,
  }) async {
    try {
      final response = await _dio.get(
        '/healthcare-centers/$centerId/doctors',
        queryParameters: {
          if (specialization != null) 'specialization': specialization,
        },
      );
      final items = response.data as List<dynamic>;
      return items
          .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<DoctorModel>> getDoctors({
    String? centerId,
    String? specialization,
    String? name,
  }) async {
    try {
      final response = await _dio.get(
        '/doctors',
        queryParameters: {
          if (centerId != null) 'centerId': centerId,
          if (specialization != null) 'specialization': specialization,
          if (name != null) 'name': name,
        },
      );
      final items = response.data as List<dynamic>;
      return items
          .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<DoctorModel> getDoctorDetail(String doctorId) async {
    try {
      final response = await _dio.get('/doctors/$doctorId');
      return DoctorModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<TimeSlot>> getDoctorAvailability({
    required String doctorId,
    required String centerId,
    required DateTime date,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '/doctors/$doctorId/availability',
        queryParameters: {'centerId': centerId, 'date': dateStr},
      );
      final items = response.data as List<dynamic>;
      return items.map((e) {
        final map = e as Map<String, dynamic>;
        return TimeSlot(
          id: map['id'] as String,
          dateTime: DateTime.parse(map['dateTime'] as String),
          isBooked: map['isBooked'] as bool? ?? false,
        );
      }).toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<DateTime>> getDoctorAvailableDates({
    required String doctorId,
    required String centerId,
    int daysAhead = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/doctors/$doctorId/available-dates',
        queryParameters: {'centerId': centerId, 'daysAhead': daysAhead},
      );
      final items = response.data as List<dynamic>;
      return items.map((e) => DateTime.parse(e.toString())).toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }
}
