import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RequestOtpUsecase {
  const RequestOtpUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call({required String phoneNumber}) =>
      _repository.requestOtp(phoneNumber: phoneNumber);
}
