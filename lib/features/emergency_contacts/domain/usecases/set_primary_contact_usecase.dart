import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/emergency_contacts_repository.dart';

class SetPrimaryContactUsecase {
  SetPrimaryContactUsecase(this._repository);
  final EmergencyContactsRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.setPrimary(id);
}
