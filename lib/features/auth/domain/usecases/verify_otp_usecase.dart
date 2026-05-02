import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({required this.phoneNumber, required this.otpCode});

  final String phoneNumber;
  final String otpCode;
}

class VerifyOtpUsecase {
  const VerifyOtpUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call(VerifyOtpParams params) => _repository
      .verifyOtp(phoneNumber: params.phoneNumber, otpCode: params.otpCode);
}
