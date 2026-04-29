import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_reminder.dart';

abstract class MedicationRemindersState extends Equatable {
  const MedicationRemindersState();
  @override
  List<Object?> get props => [];
}

class MedicationRemindersInitial extends MedicationRemindersState {
  const MedicationRemindersInitial();
}

class MedicationRemindersLoading extends MedicationRemindersState {
  const MedicationRemindersLoading();
}

class MedicationRemindersLoaded extends MedicationRemindersState {
  const MedicationRemindersLoaded(this.reminders);
  final List<MedicationReminder> reminders;
  @override
  List<Object?> get props => [reminders];
}

class MedicationReminderAdding extends MedicationRemindersState {
  const MedicationReminderAdding();
}

class MedicationReminderActionSuccess extends MedicationRemindersState {
  const MedicationReminderActionSuccess({
    required this.reminders,
    required this.message,
  });
  final List<MedicationReminder> reminders;
  final String message;
  @override
  List<Object?> get props => [reminders, message];
}

class MedicationRemindersFailure extends MedicationRemindersState {
  const MedicationRemindersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
