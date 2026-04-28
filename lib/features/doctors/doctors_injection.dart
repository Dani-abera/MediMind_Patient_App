import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/doctors_remote_datasource.dart';
import 'data/repositories/doctors_repository_impl.dart';
import 'domain/repositories/doctors_repository.dart';
import 'domain/usecases/get_availability_usecase.dart';
import 'domain/usecases/get_available_dates_usecase.dart';
import 'domain/usecases/get_center_doctors_usecase.dart';
import 'domain/usecases/get_doctor_detail_usecase.dart';
import '../appointments/presentation/bloc/slot_picker/slot_picker_bloc.dart';

void initDoctorsFeature(GetIt sl) {
  sl.registerLazySingleton<DoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepositoryImpl(sl<DoctorsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => GetCenterDoctorsUsecase(sl<DoctorsRepository>()));
  sl.registerLazySingleton(
      () => GetDoctorDetailUsecase(sl<DoctorsRepository>()));
  sl.registerLazySingleton(
      () => GetAvailabilityUsecase(sl<DoctorsRepository>()));
  sl.registerLazySingleton(
      () => GetAvailableDatesUsecase(sl<DoctorsRepository>()));

  sl.registerFactory(
    () => SlotPickerBloc(
      getAvailableDates: sl<GetAvailableDatesUsecase>(),
      getAvailability: sl<GetAvailabilityUsecase>(),
    ),
  );
}
