import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../appointments/domain/entities/time_slot.dart';
import '../repositories/doctors_repository.dart';

class GetAvailabilityParams extends Equatable {
  const GetAvailabilityParams({
    required this.doctorId,
    required this.centerId,
    required this.date,
  });

  final String doctorId;
  final String centerId;
  final DateTime date;

  @override
  List<Object?> get props => [doctorId, centerId, date];
}

class GetAvailabilityUsecase {
  const GetAvailabilityUsecase(this._repository);
  final DoctorsRepository _repository;

  Future<Either<Failure, List<TimeSlot>>> call(GetAvailabilityParams params) =>
      _repository.getDoctorAvailability(
        doctorId: params.doctorId,
        centerId: params.centerId,
        date: params.date,
      );
}
