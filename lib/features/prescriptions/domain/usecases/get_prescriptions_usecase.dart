import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription.dart';
import '../repositories/prescriptions_repository.dart';

class GetPrescriptionsUsecase {
  GetPrescriptionsUsecase(this._repository);
  final PrescriptionsRepository _repository;

  Future<Either<Failure, List<Prescription>>> call({int page = 1, int pageSize = 20}) =>
      _repository.getPrescriptions(page: page, pageSize: pageSize);
}
