import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/doctors_repository.dart';

class GetAvailableDatesParams extends Equatable {
  const GetAvailableDatesParams({
    required this.doctorId,
    required this.centerId,
    this.daysAhead = 30,
  });

  final String doctorId;
  final String centerId;
  final int daysAhead;

  @override
  List<Object?> get props => [doctorId, centerId, daysAhead];
}

class GetAvailableDatesUsecase {
  const GetAvailableDatesUsecase(this._repository);
  final DoctorsRepository _repository;

  Future<Either<Failure, List<DateTime>>> call(
    GetAvailableDatesParams params,
  ) =>
      _repository.getDoctorAvailableDates(
        doctorId: params.doctorId,
        centerId: params.centerId,
        daysAhead: params.daysAhead,
      );
}
