import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/usecases/add_reminder_usecase.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/toggle_reminder_usecase.dart';
import 'medication_reminders_event.dart';
import 'medication_reminders_state.dart';

class MedicationRemindersBloc
    extends Bloc<MedicationRemindersEvent, MedicationRemindersState> {
  MedicationRemindersBloc({
    required GetRemindersUsecase getReminders,
    required AddReminderUsecase addReminder,
    required DeleteReminderUsecase deleteReminder,
    required ToggleReminderUsecase toggleReminder,
    required NotificationService notificationService,
  })  : _getReminders = getReminders,
        _addReminder = addReminder,
        _deleteReminder = deleteReminder,
        _toggleReminder = toggleReminder,
        _notifications = notificationService,
        super(const MedicationRemindersInitial()) {
    on<MedicationRemindersRequested>(_onRequested, transformer: droppable());
    on<MedicationReminderAdded>(_onAdded);
    on<MedicationReminderToggled>(_onToggled);
    on<MedicationReminderDeleted>(_onDeleted);
  }

  final GetRemindersUsecase _getReminders;
  final AddReminderUsecase _addReminder;
  final DeleteReminderUsecase _deleteReminder;
  final ToggleReminderUsecase _toggleReminder;
  final NotificationService _notifications;

  Future<void> _onRequested(MedicationRemindersRequested event,
      Emitter<MedicationRemindersState> emit) async {
    emit(const MedicationRemindersLoading());
    final result = await _getReminders();
    result.fold(
      (failure) => emit(MedicationRemindersFailure(failure.message)),
      (reminders) => emit(MedicationRemindersLoaded(reminders)),
    );
  }

  Future<void> _onAdded(MedicationReminderAdded event,
      Emitter<MedicationRemindersState> emit) async {
    emit(const MedicationReminderAdding());

    final params = AddReminderParams(
      medicationName: event.medicationName,
      dosage: event.dosage,
      frequency: event.frequency,
      times: event.times,
      startDate: event.startDate,
      endDate: event.endDate,
      notes: event.notes,
    );

    final result = await _addReminder(params);
    await result.fold(
      (failure) async =>
          emit(MedicationRemindersFailure(failure.message)),
      (reminder) async {
        // Schedule local notifications 15 min before each dose
        final baseId = reminder.id.hashCode.abs() % 100000;
        await _notifications.scheduleAllTimes(
          baseId: baseId,
          medicationName: reminder.medicationName,
          dosage: reminder.dosage,
          times: reminder.times,
        );
        add(const MedicationRemindersRequested());
        emit(MedicationReminderActionSuccess(
          reminders: _currentReminders,
          message: '${reminder.medicationName} reminder added',
        ));
      },
    );
  }

  Future<void> _onToggled(MedicationReminderToggled event,
      Emitter<MedicationRemindersState> emit) async {
    final result = await _toggleReminder(event.id);
    await result.fold(
      (failure) async =>
          emit(MedicationRemindersFailure(failure.message)),
      (reminder) async {
        // Cancel or reschedule notifications on toggle
        final baseId = reminder.id.hashCode.abs() % 100000;
        for (var i = 0; i < reminder.times.length; i++) {
          await _notifications.cancelReminder(baseId + i);
        }
        if (reminder.isActive) {
          await _notifications.scheduleAllTimes(
            baseId: baseId,
            medicationName: reminder.medicationName,
            dosage: reminder.dosage,
            times: reminder.times,
          );
        }
        add(const MedicationRemindersRequested());
      },
    );
  }

  Future<void> _onDeleted(MedicationReminderDeleted event,
      Emitter<MedicationRemindersState> emit) async {
    final current = _currentReminders;
    final reminder = current.where((r) => r.id == event.id).firstOrNull;

    final result = await _deleteReminder(event.id);
    await result.fold(
      (failure) async =>
          emit(MedicationRemindersFailure(failure.message)),
      (_) async {
        if (reminder != null) {
          final baseId = reminder.id.hashCode.abs() % 100000;
          for (var i = 0; i < reminder.times.length; i++) {
            await _notifications.cancelReminder(baseId + i);
          }
        }
        add(const MedicationRemindersRequested());
        emit(MedicationReminderActionSuccess(
          reminders: current.where((r) => r.id != event.id).toList(),
          message: 'Reminder deleted',
        ));
      },
    );
  }

  List<MedicationReminder> get _currentReminders {
    final s = state;
    if (s is MedicationRemindersLoaded) return s.reminders;
    if (s is MedicationReminderActionSuccess) return s.reminders;
    return const [];
  }
}
