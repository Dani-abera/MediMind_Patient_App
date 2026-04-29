import 'package:get_it/get_it.dart';
import '../../core/storage/preferences_storage.dart';
import 'presentation/bloc/settings_bloc.dart';

void initSettingsFeature(GetIt sl) {
  sl.registerFactory(
    () => SettingsBloc(storage: sl<PreferencesStorage>()),
  );
}
