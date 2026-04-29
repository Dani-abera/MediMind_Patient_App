import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_contact.dart';
import '../repositories/emergency_contacts_repository.dart';

class UpdateContactUsecase {
  UpdateContactUsecase(this._repository);
  final EmergencyContactsRepository _repository;

  Future<Either<Failure, EmergencyContact>> call(EmergencyContact contact) =>
      _repository.updateContact(contact);
}
