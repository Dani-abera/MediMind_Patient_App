import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_detail.dart';
import '../repositories/appointments_repository.dart';

class GetAppointmentDetailUsecase {
  const GetAppointmentDetailUsecase(this._repository);
  final AppointmentsRepository _repository;

  Future<Either<Failure, AppointmentDetail>> call(String appointmentId) =>
      _repository.getAppointmentDetail(appointmentId);
}
