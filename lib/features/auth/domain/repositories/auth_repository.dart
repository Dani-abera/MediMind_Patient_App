import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

abstract class AuthRepository {
  Future<Either<Failure, void>> registerPatient({
    required String fullName,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    String? email,
  });

  Future<Either<Failure, void>> requestOtp({
    required String phoneNumber,
  });

  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });

  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Stream<AuthStatus> get authStatusStream;
}
