import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/centers_remote_datasource.dart';
import 'data/repositories/centers_repository_impl.dart';
import 'domain/repositories/centers_repository.dart';
import 'domain/usecases/get_center_detail_usecase.dart';
import 'domain/usecases/get_centers_usecase.dart';
import 'domain/usecases/get_nearby_centers_usecase.dart';
import 'presentation/bloc/centers_bloc.dart';

void initCentersFeature(GetIt sl) {
  sl.registerLazySingleton<CentersRemoteDataSource>(
    () => CentersRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<CentersRepository>(
    () => CentersRepositoryImpl(sl<CentersRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetCentersUsecase(sl<CentersRepository>()));
  sl.registerLazySingleton(
      () => GetNearbyCentersUsecase(sl<CentersRepository>()));
  sl.registerLazySingleton(
      () => GetCenterDetailUsecase(sl<CentersRepository>()));

  sl.registerFactory(
    () => CentersBloc(getCenters: sl<GetCentersUsecase>()),
  );
}
