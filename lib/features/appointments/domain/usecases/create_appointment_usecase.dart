import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_detail.dart';
import '../repositories/appointments_repository.dart';

class CreateAppointmentParams extends Equatable {
  const CreateAppointmentParams({
    required this.doctorId,
    required this.centerId,
    required this.appointmentTime,
    required this.slotId,
    this.reasonForVisit,
    this.symptoms,
  });

  final String doctorId;
  final String centerId;
  final DateTime appointmentTime;
  final String slotId;
  final String? reasonForVisit;
  final String? symptoms;

  @override
  List<Object?> get props => [doctorId, centerId, appointmentTime, slotId];
}

class CreateAppointmentUsecase {
  const CreateAppointmentUsecase(this._repository);
  final AppointmentsRepository _repository;

  Future<Either<Failure, AppointmentDetail>> call(
    CreateAppointmentParams params,
  ) =>
      _repository.createAppointment(
        doctorId: params.doctorId,
        centerId: params.centerId,
        appointmentTime: params.appointmentTime,
        slotId: params.slotId,
        reasonForVisit: params.reasonForVisit,
        symptoms: params.symptoms,
      );
}
