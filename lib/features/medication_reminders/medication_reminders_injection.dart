import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/medication_reminders_remote_datasource.dart';
import 'data/repositories/medication_reminders_repository_impl.dart';
import 'domain/repositories/medication_reminders_repository.dart';
import 'domain/usecases/add_reminder_usecase.dart';
import 'domain/usecases/delete_reminder_usecase.dart';
import 'domain/usecases/get_reminders_usecase.dart';
import 'domain/usecases/toggle_reminder_usecase.dart';
import 'domain/usecases/update_reminder_usecase.dart';

void initMedicationRemindersFeature(GetIt sl) {
  sl.registerLazySingleton<MedicationRemindersRemoteDataSource>(
      () => MedicationRemindersRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<MedicationRemindersRepository>(() =>
      MedicationRemindersRepositoryImpl(
          sl<MedicationRemindersRemoteDataSource>()));

  sl.registerLazySingleton(
      () => GetRemindersUsecase(sl<MedicationRemindersRepository>()));
  sl.registerLazySingleton(
      () => AddReminderUsecase(sl<MedicationRemindersRepository>()));
  sl.registerLazySingleton(
      () => UpdateReminderUsecase(sl<MedicationRemindersRepository>()));
  sl.registerLazySingleton(
      () => DeleteReminderUsecase(sl<MedicationRemindersRepository>()));
  sl.registerLazySingleton(
      () => ToggleReminderUsecase(sl<MedicationRemindersRepository>()));
}
