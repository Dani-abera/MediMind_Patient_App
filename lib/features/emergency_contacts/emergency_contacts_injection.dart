import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/emergency_contacts_remote_datasource.dart';
import 'data/repositories/emergency_contacts_repository_impl.dart';
import 'domain/repositories/emergency_contacts_repository.dart';
import 'domain/usecases/add_contact_usecase.dart';
import 'domain/usecases/delete_contact_usecase.dart';
import 'domain/usecases/get_contacts_usecase.dart';
import 'domain/usecases/set_primary_contact_usecase.dart';
import 'domain/usecases/update_contact_usecase.dart';
import 'presentation/bloc/emergency_contacts_bloc.dart';

void initEmergencyContactsFeature(GetIt sl) {
  sl.registerLazySingleton<EmergencyContactsRemoteDataSource>(
    () => EmergencyContactsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<EmergencyContactsRepository>(
    () => EmergencyContactsRepositoryImpl(
        sl<EmergencyContactsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => GetContactsUsecase(sl<EmergencyContactsRepository>()));
  sl.registerLazySingleton(
      () => AddContactUsecase(sl<EmergencyContactsRepository>()));
  sl.registerLazySingleton(
      () => UpdateContactUsecase(sl<EmergencyContactsRepository>()));
  sl.registerLazySingleton(
      () => DeleteContactUsecase(sl<EmergencyContactsRepository>()));
  sl.registerLazySingleton(
      () => SetPrimaryContactUsecase(sl<EmergencyContactsRepository>()));

  sl.registerFactory(
    () => EmergencyContactsBloc(
      getContacts: sl<GetContactsUsecase>(),
      addContact: sl<AddContactUsecase>(),
      updateContact: sl<UpdateContactUsecase>(),
      deleteContact: sl<DeleteContactUsecase>(),
      setPrimary: sl<SetPrimaryContactUsecase>(),
    ),
  );
}
