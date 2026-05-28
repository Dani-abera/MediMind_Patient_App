import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/repositories/medication_reminders_repository.dart';
import '../datasources/medication_reminders_remote_datasource.dart';
import '../models/medication_reminder_model.dart';

const _freqReverseMap = {
  ReminderFrequency.once: 'once',
  ReminderFrequency.twice: 'twice',
  ReminderFrequency.threeTimes: 'threeTimes',
  ReminderFrequency.fourTimes: 'fourTimes',
  ReminderFrequency.custom: 'custom',
};

class MedicationRemindersRepositoryImpl
    implements MedicationRemindersRepository {
  const MedicationRemindersRepositoryImpl(this._remote);
  final MedicationRemindersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<MedicationReminder>>> getReminders() =>
      _wrapList(() => _remote.getReminders());

  @override
  Future<Either<Failure, MedicationReminder>> addReminder({
    required String medicationName,
    required String dosage,
    required ReminderFrequency frequency,
    required List<String> times,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) =>
      _wrap(() => _remote.addReminder({
            'medicationName': medicationName,
            'dosage': dosage,
            'frequency': _freqReverseMap[frequency],
            'reminderTimes': times,
            'startDate': startDate.toIso8601String(),
            if (endDate != null) 'endDate': endDate.toIso8601String(),
            if (notes != null) 'notes': notes,
          }));

  @override
  Future<Either<Failure, MedicationReminder>> updateReminder(
          MedicationReminder reminder) =>
      _wrap(() => _remote.updateReminder(
            reminder.id,
            MedicationReminderModel(
              id: reminder.id,
              medicationName: reminder.medicationName,
              dosage: reminder.dosage,
              frequency: reminder.frequency,
              times: reminder.times,
              isActive: reminder.isActive,
              startDate: reminder.startDate,
              endDate: reminder.endDate,
              notes: reminder.notes,
              notificationIds: reminder.notificationIds,
            ).toJson(),
          ));

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    try {
      await _remote.deleteReminder(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MedicationReminder>> toggleReminder(String id) =>
      _wrap(() => _remote.toggleReminder(id));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<T>>> _wrapList<T>(
      Future<List<T>> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
