import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_detail.dart';
import '../repositories/appointments_repository.dart';

class GetUpcomingAppointmentsUsecase {
  const GetUpcomingAppointmentsUsecase(this._repository);
  final AppointmentsRepository _repository;

  Future<Either<Failure, List<AppointmentDetail>>> call() =>
      _repository.getUpcomingAppointments();
}
