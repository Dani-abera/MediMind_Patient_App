import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_item.dart';
import 'notifications_list_event.dart';
import 'notifications_list_state.dart';

class NotificationsListBloc
    extends Bloc<NotificationsListEvent, NotificationsListState> {
  NotificationsListBloc({required NotificationRemoteDataSource dataSource})
      : _ds = dataSource,
        super(const NotificationsListState()) {
    on<NotificationsListRequested>(_onRequested);
    on<NotificationsListRefreshed>(_onRequested, transformer: restartable());
    on<NotificationMarkedRead>(_onMarkRead);
    on<NotificationsAllMarkedRead>(_onMarkAllRead);
    on<NotificationPreferencesRequested>(_onPrefsRequested);
    on<NotificationPreferenceUpdated>(_onPrefUpdated,
        transformer: restartable());
  }

  final NotificationRemoteDataSource _ds;
  Timer? _prefDebounce;

  Future<void> _onRequested(
    NotificationsListEvent event,
    Emitter<NotificationsListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await _ds.getNotifications();
      emit(state.copyWith(notifications: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkedRead event,
    Emitter<NotificationsListState> emit,
  ) async {
    try {
      await _ds.markRead(event.id);
      final updated = state.notifications
          .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(state.copyWith(notifications: updated));
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(
    NotificationsAllMarkedRead event,
    Emitter<NotificationsListState> emit,
  ) async {
    try {
      await _ds.markAllRead();
      final updated =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(state.copyWith(notifications: updated));
    } catch (_) {}
  }

  Future<void> _onPrefsRequested(
    NotificationPreferencesRequested event,
    Emitter<NotificationsListState> emit,
  ) async {
    try {
      final prefs = await _ds.getPreferences();
      emit(state.copyWith(preferences: prefs));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onPrefUpdated(
    NotificationPreferenceUpdated event,
    Emitter<NotificationsListState> emit,
  ) async {
    if (state.preferences == null) return;
    final updated = _applyPrefKey(state.preferences!, event.key, event.value);
    emit(state.copyWith(preferences: updated));

    _prefDebounce?.cancel();
    final completer = Completer<void>();
    _prefDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isSavingPrefs: true));
        await _ds.updatePreferences(updated.toJson());
      } catch (_) {
      } finally {
        emit(state.copyWith(isSavingPrefs: false));
      }
      completer.complete();
    });
    await completer.future;
  }

  NotificationPreferences _applyPrefKey(
      NotificationPreferences prefs, String key, bool value) {
    switch (key) {
      case 'appointmentReminders':
        return prefs.copyWith(appointmentReminders: value);
      case 'appointmentSms':
        return prefs.copyWith(appointmentSms: value);
      case 'queueUpdates':
        return prefs.copyWith(queueUpdates: value);
      case 'predictionReady':
        return prefs.copyWith(predictionReady: value);
      case 'medicationReminders':
        return prefs.copyWith(medicationReminders: value);
      case 'promotional':
        return prefs.copyWith(promotional: value);
      default:
        return prefs;
    }
  }

  @override
  Future<void> close() {
    _prefDebounce?.cancel();
    return super.close();
  }
}
