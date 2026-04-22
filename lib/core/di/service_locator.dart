import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../services/connectivity_service.dart';
import '../storage/preferences_storage.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core singletons
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<PreferencesStorage>(
    () => PreferencesStorage(prefs),
  );

  sl.registerLazySingleton<Dio>(
    () => DioClient.createDio(sl<SecureStorage>()),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(InternetConnection()),
  );

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(Connectivity()),
  );

  sl.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(methodCount: 2, lineLength: 120),
    ),
  );
}
