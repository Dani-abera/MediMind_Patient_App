import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/video_consultation_remote_datasource.dart';
import 'data/repositories/video_consultation_repository_impl.dart';
import 'domain/repositories/video_consultation_repository.dart';
import 'domain/usecases/get_consultation_usecase.dart';
import 'domain/usecases/join_consultation_usecase.dart';
import 'services/video_signalr_service.dart';

void initVideoConsultationFeature(GetIt sl) {
  sl.registerLazySingleton<VideoConsultationRemoteDataSource>(
      () => VideoConsultationRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<VideoConsultationRepository>(
      () => VideoConsultationRepositoryImpl(
          sl<VideoConsultationRemoteDataSource>()));

  sl.registerLazySingleton(
      () => GetConsultationUsecase(sl<VideoConsultationRepository>()));
  sl.registerLazySingleton(
      () => JoinConsultationUsecase(sl<VideoConsultationRepository>()));

  sl.registerFactory(
    () => VideoSignalRService(secureStorage: sl<SecureStorage>()),
  );
}
