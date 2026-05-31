import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor.dart';
import '../repositories/doctors_repository.dart';

class GetDoctorDetailUsecase {
  const GetDoctorDetailUsecase(this._repository);
  final DoctorsRepository _repository;

  Future<Either<Failure, Doctor>> call(String doctorId, {String? centerId}) =>
      _repository.getDoctorDetail(doctorId, centerId: centerId);
}
