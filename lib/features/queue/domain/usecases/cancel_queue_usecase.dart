import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/queue_repository.dart';

class CancelQueueUsecase {
  CancelQueueUsecase(this._repository);
  final QueueRepository _repository;

  Future<Either<Failure, void>> call(String appointmentId) =>
      _repository.cancelQueuePosition(appointmentId);
}
