import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_reminder.dart';

abstract class MedicationRemindersRepository {
  Future<Either<Failure, List<MedicationReminder>>> getReminders();
  Future<Either<Failure, MedicationReminder>> addReminder({
    required String medicationName,
    required String dosage,
    required ReminderFrequency frequency,
    required List<String> times,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  });
  Future<Either<Failure, MedicationReminder>> updateReminder(
      MedicationReminder reminder);
  Future<Either<Failure, void>> deleteReminder(String id);
  Future<Either<Failure, MedicationReminder>> toggleReminder(String id);
}
