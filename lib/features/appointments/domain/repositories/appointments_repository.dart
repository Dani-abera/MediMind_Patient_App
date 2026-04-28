import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_detail.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, AppointmentDetail>> createAppointment({
    required String doctorId,
    required String centerId,
    required DateTime appointmentTime,
    required String slotId,
    String? reasonForVisit,
    String? symptoms,
  });

  Future<Either<Failure, List<AppointmentDetail>>> getUpcomingAppointments();

  Future<Either<Failure, List<AppointmentDetail>>> getPastAppointments({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, AppointmentDetail>> getAppointmentDetail(
    String appointmentId,
  );

  Future<Either<Failure, void>> cancelAppointment(String appointmentId);
}
