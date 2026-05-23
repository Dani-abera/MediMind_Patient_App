import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

import '../models/otp_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    AuthEventBus.instance.events.listen((event) {
      if (event == AuthEvent.logout) {
        _authStatusController.add(AuthStatus.unauthenticated);
      }
    });
  }

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  final _authStatusController = StreamController<AuthStatus>.broadcast();

  @override
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  @override
  Future<Either<Failure, void>> registerPatient({
    required String fullName,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    String? email,
  }) async {
    try {
      await remoteDataSource.registerPatient(
        RegisterRequestModel(
          fullName: fullName,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          gender: gender,
          email: email,
        ),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(ServerFailure(message: e.message, code: 409));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.requestOtp(
        OtpRequestModel(phoneNumber: phoneNumber),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final tokens = await remoteDataSource.verifyOtp(
        OtpVerifyRequestModel(phoneNumber: phoneNumber, otpCode: otpCode),
      );
      await localDataSource.saveTokens(tokens);
      
      final user = UserModel(
        patientId: tokens.userId,
        fullName: tokens.fullName,
        phoneNumber: phoneNumber,
        isProfileComplete: tokens.isProfileComplete,
      );
      
      await localDataSource.cacheUser(user);
      _authStatusController.add(AuthStatus.authenticated);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final tokens = await localDataSource.getTokens();
      final isAuthenticated = tokens != null;
      _authStatusController.add(
        isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
      return Right(isAuthenticated);
    } catch (_) {
      _authStatusController.add(AuthStatus.unauthenticated);
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final tokens = await localDataSource.getTokens();
      if (tokens != null) {
        await remoteDataSource.logout(tokens.refreshToken);
      }
    } catch (_) {
      // Best-effort remote logout; always clear local state
    }
    await localDataSource.clearTokens();
    await localDataSource.clearCache();
    _authStatusController.add(AuthStatus.unauthenticated);
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
