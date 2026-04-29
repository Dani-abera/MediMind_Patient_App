import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'presentation/bloc/notification_bloc.dart';
import 'presentation/bloc/notifications_list_bloc.dart';

void initNotificationsFeature(GetIt sl) {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton(
    () => NotificationBloc(dataSource: sl<NotificationRemoteDataSource>()),
  );

  sl.registerFactory(
    () => NotificationsListBloc(
        dataSource: sl<NotificationRemoteDataSource>()),
  );
}
