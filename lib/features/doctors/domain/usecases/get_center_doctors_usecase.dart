import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor.dart';
import '../repositories/doctors_repository.dart';

class GetCenterDoctorsUsecase {
  const GetCenterDoctorsUsecase(this._repository);
  final DoctorsRepository _repository;

  Future<Either<Failure, List<Doctor>>> call(
    String centerId, {
    String? specialization,
  }) =>
      _repository.getCenterDoctors(centerId, specialization: specialization);
}
