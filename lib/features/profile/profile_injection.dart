import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/profile_remote_datasource.dart';
import 'presentation/bloc/profile_bloc.dart';

void initProfileFeature(GetIt sl) {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerFactory(
    () => ProfileBloc(dataSource: sl<ProfileRemoteDataSource>()),
  );
}
