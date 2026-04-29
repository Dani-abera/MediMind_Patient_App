import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/health_records_remote_datasource.dart';
import 'data/repositories/health_records_repository_impl.dart';
import 'domain/repositories/health_records_repository.dart';
import 'domain/usecases/delete_record_usecase.dart';
import 'domain/usecases/get_health_records_usecase.dart';
import 'domain/usecases/get_latest_record_usecase.dart';
import 'domain/usecases/get_record_count_usecase.dart';
import 'domain/usecases/get_trends_usecase.dart';
import 'domain/usecases/log_vitals_usecase.dart';

void initHealthRecordsFeature(GetIt sl) {
  sl.registerLazySingleton<HealthRecordsRemoteDataSource>(
      () => HealthRecordsRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<HealthRecordsRepository>(
      () => HealthRecordsRepositoryImpl(sl<HealthRecordsRemoteDataSource>()));

  sl.registerLazySingleton(() => LogVitalsUsecase(sl<HealthRecordsRepository>()));
  sl.registerLazySingleton(
      () => GetHealthRecordsUsecase(sl<HealthRecordsRepository>()));
  sl.registerLazySingleton(
      () => GetLatestRecordUsecase(sl<HealthRecordsRepository>()));
  sl.registerLazySingleton(
      () => GetTrendsUsecase(sl<HealthRecordsRepository>()));
  sl.registerLazySingleton(
      () => GetRecordCountUsecase(sl<HealthRecordsRepository>()));
  sl.registerLazySingleton(
      () => DeleteRecordUsecase(sl<HealthRecordsRepository>()));
}
