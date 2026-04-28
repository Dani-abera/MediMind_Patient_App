import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/appointments_remote_datasource.dart';
import 'data/repositories/appointments_repository_impl.dart';
import 'domain/repositories/appointments_repository.dart';
import 'domain/usecases/cancel_appointment_usecase.dart';
import 'domain/usecases/create_appointment_usecase.dart';
import 'domain/usecases/get_appointment_detail_usecase.dart';
import 'domain/usecases/get_upcoming_appointments_usecase.dart';
import 'presentation/bloc/appointments/appointments_bloc.dart';
import 'presentation/bloc/booking_flow/booking_flow_bloc.dart';
import '../payments/domain/usecases/initiate_payment_usecase.dart';

void initAppointmentsFeature(GetIt sl) {
  sl.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(sl<AppointmentsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => CreateAppointmentUsecase(sl<AppointmentsRepository>()));
  sl.registerLazySingleton(
      () => GetUpcomingAppointmentsUsecase(sl<AppointmentsRepository>()));
  sl.registerLazySingleton(
      () => GetAppointmentDetailUsecase(sl<AppointmentsRepository>()));
  sl.registerLazySingleton(
      () => CancelAppointmentUsecase(sl<AppointmentsRepository>()));

  sl.registerFactory(
    () => AppointmentsBloc(
      getUpcoming: sl<GetUpcomingAppointmentsUsecase>(),
      getDetail: sl<GetAppointmentDetailUsecase>(),
      cancelAppointment: sl<CancelAppointmentUsecase>(),
    ),
  );

  sl.registerFactory(
    () => BookingFlowBloc(
      createAppointment: sl<CreateAppointmentUsecase>(),
      initiatePayment: sl<InitiatePaymentUsecase>(),
    ),
  );
}
