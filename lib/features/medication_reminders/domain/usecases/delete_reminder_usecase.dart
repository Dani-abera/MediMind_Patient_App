import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/medication_reminders_repository.dart';

class DeleteReminderUsecase {
  const DeleteReminderUsecase(this._repository);
  final MedicationRemindersRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteReminder(id);
}
