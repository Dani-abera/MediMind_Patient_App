import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contacts_repository.dart';
import '../datasources/emergency_contacts_remote_datasource.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactsRepositoryImpl implements EmergencyContactsRepository {
  EmergencyContactsRepositoryImpl(this._dataSource);
  final EmergencyContactsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<EmergencyContact>>> getContacts() async {
    try { return Right(await _dataSource.getContacts()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, EmergencyContact>> addContact({
    required String fullName, required String relationship,
    required String phoneNumber, required bool isPrimary,
  }) async {
    try {
      return Right(await _dataSource.addContact({
        'fullName': fullName, 'relationship': relationship,
        'phoneNumber': phoneNumber, 'isPrimary': isPrimary,
      }));
    }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, EmergencyContact>> updateContact(EmergencyContact contact) async {
    try {
      final model = EmergencyContactModel(
        id: contact.id, fullName: contact.fullName,
        relationship: contact.relationship, phoneNumber: contact.phoneNumber,
        isPrimary: contact.isPrimary,
      );
      return Right(await _dataSource.updateContact(contact.id, model.toJson()));
    }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> deleteContact(String id) async {
    try { await _dataSource.deleteContact(id); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> setPrimary(String id) async {
    try { await _dataSource.setPrimary(id); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
}
