import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterPatientParams {
  const RegisterPatientParams({
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.email,
  });

  final String fullName;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String? email;
}

class RegisterPatientUsecase {
  const RegisterPatientUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call(RegisterPatientParams params) =>
      _repository.registerPatient(
        fullName: params.fullName,
        phoneNumber: params.phoneNumber,
        dateOfBirth: params.dateOfBirth,
        gender: params.gender,
        email: params.email,
      );
}
