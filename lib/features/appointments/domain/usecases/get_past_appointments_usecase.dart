import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_detail.dart';
import '../repositories/appointments_repository.dart';

class GetPastAppointmentsUsecase {
  const GetPastAppointmentsUsecase(this._repo);
  final AppointmentsRepository _repo;

  Future<Either<Failure, List<AppointmentDetail>>> call({
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getPastAppointments(page: page, pageSize: pageSize);
}
