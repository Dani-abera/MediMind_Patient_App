import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/queue_remote_datasource.dart';
import 'data/repositories/queue_repository_impl.dart';
import 'domain/repositories/queue_repository.dart';
import 'domain/usecases/cancel_queue_usecase.dart';
import 'domain/usecases/get_queue_status_usecase.dart';
import 'services/queue_signalr_service.dart';

void initQueueFeature(GetIt sl) {
  sl.registerLazySingleton<QueueRemoteDataSource>(
      () => QueueRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<QueueRepository>(
      () => QueueRepositoryImpl(sl<QueueRemoteDataSource>()));

  sl.registerLazySingleton(
      () => GetQueueStatusUsecase(sl<QueueRepository>()));
  sl.registerLazySingleton(
      () => CancelQueueUsecase(sl<QueueRepository>()));

  sl.registerFactory(
    () => QueueSignalRService(secureStorage: sl<SecureStorage>()),
  );
}
