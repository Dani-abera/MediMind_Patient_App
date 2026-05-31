import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../appointments/domain/entities/time_slot.dart';
import '../entities/doctor.dart';

abstract class DoctorsRepository {
  Future<Either<Failure, List<Doctor>>> getCenterDoctors(
    String centerId, {
    String? specialization,
  });

  Future<Either<Failure, List<Doctor>>> getDoctors({
    String? centerId,
    String? specialization,
    String? name,
  });

  Future<Either<Failure, Doctor>> getDoctorDetail(String doctorId, {String? centerId});

  Future<Either<Failure, List<TimeSlot>>> getDoctorAvailability({
    required String doctorId,
    required String centerId,
    required DateTime date,
  });

  Future<Either<Failure, List<DateTime>>> getDoctorAvailableDates({
    required String doctorId,
    required String centerId,
    int daysAhead = 30,
  });
}
