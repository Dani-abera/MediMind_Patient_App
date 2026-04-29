import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/favorites_remote_datasource.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'domain/repositories/favorites_repository.dart';
import 'presentation/bloc/favorites_bloc.dart';

void initFavoritesFeature(GetIt sl) {
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
  );

  sl.registerFactory(
    () => FavoritesBloc(repository: sl<FavoritesRepository>()),
  );
}
