import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../../auth/domain/usecases/delete_account_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required PreferencesStorage storage,
    required DeleteAccountUsecase deleteAccount,
  })  : _storage = storage,
        _deleteAccount = deleteAccount,
        super(const SettingsState()) {
    on<SettingsRequested>(_onRequested);
    on<SettingsThemeModeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsAccountDeleteRequested>(_onDeleteAccount);
  }

  final PreferencesStorage _storage;
  final DeleteAccountUsecase _deleteAccount;

  void _onRequested(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) {
    final lang = _storage.selectedLanguage;
    final code = lang.contains('-') ? lang.split('-').first : lang;
    emit(state.copyWith(
      themeMode: _storage.themeMode,
      languageCode: code,
    ));
  }

  Future<void> _onThemeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setThemeMode(event.mode);
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final full = event.languageCode == 'am' ? 'am-ET' : 'en-US';
    await _storage.setSelectedLanguage(full);
    emit(state.copyWith(languageCode: event.languageCode));
  }

  Future<void> _onDeleteAccount(
    SettingsAccountDeleteRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _deleteAccount();
    result.fold(
      (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, accountDeleted: true)),
    );
  }
}
