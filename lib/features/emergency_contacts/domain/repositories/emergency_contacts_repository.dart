import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_contact.dart';

abstract class EmergencyContactsRepository {
  Future<Either<Failure, List<EmergencyContact>>> getContacts();
  Future<Either<Failure, EmergencyContact>> addContact({
    required String fullName,
    required String relationship,
    required String phoneNumber,
    required bool isPrimary,
  });
  Future<Either<Failure, EmergencyContact>> updateContact(EmergencyContact contact);
  Future<Either<Failure, void>> deleteContact(String id);
  Future<Either<Failure, void>> setPrimary(String id);
}
