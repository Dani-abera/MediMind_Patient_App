import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription.dart';
import '../repositories/prescriptions_repository.dart';

class GetPrescriptionUsecase {
  GetPrescriptionUsecase(this._repository);
  final PrescriptionsRepository _repository;

  Future<Either<Failure, Prescription>> call(String id) =>
      _repository.getPrescription(id);
}
