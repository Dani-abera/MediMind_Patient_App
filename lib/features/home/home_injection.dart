import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/location_service.dart';
import 'data/datasources/home_remote_datasource.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_home_data_usecase.dart';
import 'presentation/bloc/home_bloc.dart';

void initHomeFeature(GetIt sl) {
  sl.registerLazySingleton<LocationService>(() => LocationService());

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

  sl.registerLazySingleton(
    () => GetHomeDataUsecase(
      repository: sl<HomeRepository>(),
      locationService: sl<LocationService>(),
    ),
  );

  sl.registerFactory(
    () => HomeBloc(getHomeData: sl<GetHomeDataUsecase>()),
  );
}
