import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_reminder.dart';

abstract class MedicationRemindersEvent extends Equatable {
  const MedicationRemindersEvent();
  @override
  List<Object?> get props => [];
}

class MedicationRemindersRequested extends MedicationRemindersEvent {
  const MedicationRemindersRequested();
}

class MedicationReminderAdded extends MedicationRemindersEvent {
  const MedicationReminderAdded({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes,
  });
  final String medicationName;
  final String dosage;
  final ReminderFrequency frequency;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  @override
  List<Object?> get props => [medicationName, dosage, frequency, times, startDate];
}

class MedicationReminderToggled extends MedicationRemindersEvent {
  const MedicationReminderToggled(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class MedicationReminderDeleted extends MedicationRemindersEvent {
  const MedicationReminderDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
