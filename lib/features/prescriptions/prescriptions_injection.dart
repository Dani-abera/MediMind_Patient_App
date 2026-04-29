import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/prescriptions_remote_datasource.dart';
import 'data/repositories/prescriptions_repository_impl.dart';
import 'domain/repositories/prescriptions_repository.dart';
import 'domain/usecases/get_prescription_usecase.dart';
import 'domain/usecases/get_prescriptions_usecase.dart';
import 'presentation/bloc/prescriptions_bloc.dart';

void initPrescriptionsFeature(GetIt sl) {
  sl.registerLazySingleton<PrescriptionsRemoteDataSource>(
    () => PrescriptionsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PrescriptionsRepository>(
    () => PrescriptionsRepositoryImpl(sl<PrescriptionsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => GetPrescriptionsUsecase(sl<PrescriptionsRepository>()));
  sl.registerLazySingleton(
      () => GetPrescriptionUsecase(sl<PrescriptionsRepository>()));

  sl.registerFactory(
    () => PrescriptionsBloc(
      getPrescriptions: sl<GetPrescriptionsUsecase>(),
      getPrescription: sl<GetPrescriptionUsecase>(),
    ),
  );
}
