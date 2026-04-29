import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/predictions_remote_datasource.dart';
import 'data/repositories/predictions_repository_impl.dart';
import 'domain/repositories/predictions_repository.dart';
import 'domain/usecases/get_latest_prediction_usecase.dart';
import 'domain/usecases/get_prediction_by_id_usecase.dart';
import 'domain/usecases/get_predictions_usecase.dart';
import 'domain/usecases/request_prediction_usecase.dart';

void initPredictionsFeature(GetIt sl) {
  sl.registerLazySingleton<PredictionsRemoteDataSource>(
      () => PredictionsRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<PredictionsRepository>(
      () => PredictionsRepositoryImpl(sl<PredictionsRemoteDataSource>()));

  sl.registerLazySingleton(
      () => RequestPredictionUsecase(sl<PredictionsRepository>()));
  sl.registerLazySingleton(
      () => GetPredictionsUsecase(sl<PredictionsRepository>()));
  sl.registerLazySingleton(
      () => GetLatestPredictionUsecase(sl<PredictionsRepository>()));
  sl.registerLazySingleton(
      () => GetPredictionByIdUsecase(sl<PredictionsRepository>()));
}
