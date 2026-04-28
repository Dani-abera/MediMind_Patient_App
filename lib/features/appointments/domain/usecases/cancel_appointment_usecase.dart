import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointments_repository.dart';

class CancelAppointmentUsecase {
  const CancelAppointmentUsecase(this._repository);
  final AppointmentsRepository _repository;

  Future<Either<Failure, void>> call(String appointmentId) =>
      _repository.cancelAppointment(appointmentId);
}
