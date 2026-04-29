import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_reminder.dart';
import '../repositories/medication_reminders_repository.dart';

class UpdateReminderUsecase {
  const UpdateReminderUsecase(this._repository);
  final MedicationRemindersRepository _repository;

  Future<Either<Failure, MedicationReminder>> call(
          MedicationReminder reminder) =>
      _repository.updateReminder(reminder);
}
