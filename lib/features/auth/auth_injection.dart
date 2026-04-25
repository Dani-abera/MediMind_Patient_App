import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_patient_usecase.dart';
import 'domain/usecases/request_otp_usecase.dart';
import 'domain/usecases/verify_otp_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/otp/otp_bloc.dart';
import 'presentation/bloc/register/register_bloc.dart';

Future<void> initAuthFeature(GetIt sl) async {
  final userBox = await Hive.openBox<String>('user_cache');

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl<SecureStorage>(),
      userBox: userBox,
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CheckAuthStatusUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterPatientUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RequestOtpUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepository>()));

  // BLoC — AuthBloc is a singleton (global state)
  sl.registerLazySingleton(
    () => AuthBloc(
      checkAuthStatus: sl<CheckAuthStatusUsecase>(),
      logout: sl<LogoutUsecase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Factories for screen-scoped blocs
  sl.registerFactory(
    () => OtpBloc(
      requestOtp: sl<RequestOtpUsecase>(),
      verifyOtp: sl<VerifyOtpUsecase>(),
    ),
  );
  sl.registerFactory(
    () => RegisterBloc(registerPatient: sl<RegisterPatientUsecase>()),
  );
}
