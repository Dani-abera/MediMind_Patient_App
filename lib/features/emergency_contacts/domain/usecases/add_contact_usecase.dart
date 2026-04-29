import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_contact.dart';
import '../repositories/emergency_contacts_repository.dart';

class AddContactParams extends Equatable {
  const AddContactParams({
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
    this.isPrimary = false,
  });
  final String fullName;
  final String relationship;
  final String phoneNumber;
  final bool isPrimary;
  @override
  List<Object?> get props => [fullName, relationship, phoneNumber, isPrimary];
}

class AddContactUsecase {
  AddContactUsecase(this._repository);
  final EmergencyContactsRepository _repository;

  Future<Either<Failure, EmergencyContact>> call(AddContactParams params) =>
      _repository.addContact(
        fullName: params.fullName,
        relationship: params.relationship,
        phoneNumber: params.phoneNumber,
        isPrimary: params.isPrimary,
      );
}
