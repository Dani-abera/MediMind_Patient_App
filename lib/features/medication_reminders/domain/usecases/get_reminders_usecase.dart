import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_reminder.dart';
import '../repositories/medication_reminders_repository.dart';

class GetRemindersUsecase {
  const GetRemindersUsecase(this._repository);
  final MedicationRemindersRepository _repository;

  Future<Either<Failure, List<MedicationReminder>>> call() =>
      _repository.getReminders();
}
