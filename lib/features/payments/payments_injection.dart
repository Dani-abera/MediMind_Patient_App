import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/payments_remote_datasource.dart';
import 'data/repositories/payments_repository_impl.dart';
import 'domain/repositories/payments_repository.dart';
import 'domain/usecases/get_payment_status_usecase.dart';
import 'domain/usecases/initiate_payment_usecase.dart';

void initPaymentsFeature(GetIt sl) {
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl<PaymentsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => InitiatePaymentUsecase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(
      () => GetPaymentStatusUsecase(sl<PaymentsRepository>()));
}
