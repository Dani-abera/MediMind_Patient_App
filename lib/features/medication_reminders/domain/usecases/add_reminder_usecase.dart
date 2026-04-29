import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_reminder.dart';
import '../repositories/medication_reminders_repository.dart';

class AddReminderParams {
  const AddReminderParams({
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
}

class AddReminderUsecase {
  const AddReminderUsecase(this._repository);
  final MedicationRemindersRepository _repository;

  Future<Either<Failure, MedicationReminder>> call(AddReminderParams params) =>
      _repository.addReminder(
        medicationName: params.medicationName,
        dosage: params.dosage,
        frequency: params.frequency,
        times: params.times,
        startDate: params.startDate,
        endDate: params.endDate,
        notes: params.notes,
      );
}
