import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/payments_history_datasource.dart';
import 'data/datasources/payments_remote_datasource.dart';
import 'data/repositories/payments_history_repository_impl.dart';
import 'data/repositories/payments_repository_impl.dart';
import 'domain/repositories/payments_history_repository.dart';
import 'domain/repositories/payments_repository.dart';
import 'domain/usecases/get_payment_history_usecase.dart';
import 'domain/usecases/get_payment_status_usecase.dart';
import 'domain/usecases/get_receipt_url_usecase.dart';
import 'domain/usecases/initiate_payment_usecase.dart';
import 'presentation/bloc/payments_history_bloc.dart';

void initPaymentsFeature(GetIt sl) {
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PaymentsHistoryDataSource>(
    () => PaymentsHistoryDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl<PaymentsRemoteDataSource>()),
  );

  sl.registerLazySingleton<PaymentsHistoryRepository>(
    () => PaymentsHistoryRepositoryImpl(sl<PaymentsHistoryDataSource>()),
  );

  sl.registerLazySingleton(
      () => InitiatePaymentUsecase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(
      () => GetPaymentStatusUsecase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(
      () => GetPaymentHistoryUsecase(sl<PaymentsHistoryRepository>()));
  sl.registerLazySingleton(
      () => GetReceiptUrlUsecase(sl<PaymentsRepository>()));

  sl.registerFactory(
    () => PaymentsHistoryBloc(
        getHistory: sl<GetPaymentHistoryUsecase>()),
  );
}
