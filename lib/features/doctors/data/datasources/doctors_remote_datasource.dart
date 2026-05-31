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

  Future<DoctorModel> getDoctorDetail(String doctorId, {String? centerId});

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
      final data = response.data;
      final items = (data is Map ? data['items'] : data) as List<dynamic>;
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
  Future<DoctorModel> getDoctorDetail(String doctorId, {String? centerId}) async {
    try {
      final response = await _dio.get('/doctors/$doctorId');
      return DoctorModel.fromJson(
        response.data as Map<String, dynamic>,
        centerId: centerId,
      );
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
        final timeStr = map['time'] as String? ?? '00:00:00';
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        final slotDateTime = DateTime(date.year, date.month, date.day, hour, minute);
        return TimeSlot(
          id: '${dateStr}_$timeStr',
          dateTime: slotDateTime,
          isBooked: !(map['isAvailable'] as bool? ?? true),
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
