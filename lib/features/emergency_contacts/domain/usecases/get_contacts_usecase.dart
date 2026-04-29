import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_contact.dart';
import '../repositories/emergency_contacts_repository.dart';

class GetContactsUsecase {
  GetContactsUsecase(this._repository);
  final EmergencyContactsRepository _repository;

  Future<Either<Failure, List<EmergencyContact>>> call() =>
      _repository.getContacts();
}
