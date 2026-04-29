import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_status.dart';
import '../repositories/queue_repository.dart';

class GetQueueStatusUsecase {
  GetQueueStatusUsecase(this._repository);
  final QueueRepository _repository;

  Future<Either<Failure, QueueStatus>> call(String appointmentId) =>
      _repository.getQueueStatus(appointmentId);
}
