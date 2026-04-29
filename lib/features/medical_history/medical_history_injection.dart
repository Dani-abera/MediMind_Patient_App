import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/medical_history_remote_datasource.dart';
import 'data/repositories/medical_history_repository_impl.dart';
import 'domain/repositories/medical_history_repository.dart';
import 'domain/usecases/get_medical_history_usecase.dart';
import 'domain/usecases/update_medical_history_usecase.dart';
import 'presentation/bloc/medical_history_bloc.dart';

void initMedicalHistoryFeature(GetIt sl) {
  sl.registerLazySingleton<MedicalHistoryRemoteDataSource>(
    () => MedicalHistoryRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<MedicalHistoryRepository>(
    () => MedicalHistoryRepositoryImpl(sl<MedicalHistoryRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => GetMedicalHistoryUsecase(sl<MedicalHistoryRepository>()));
  sl.registerLazySingleton(
      () => UpdateMedicalHistoryUsecase(sl<MedicalHistoryRepository>()));

  sl.registerFactory(
    () => MedicalHistoryBloc(
      getMedicalHistory: sl<GetMedicalHistoryUsecase>(),
      updateMedicalHistory: sl<UpdateMedicalHistoryUsecase>(),
    ),
  );
}
