import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_status.dart';

abstract class QueueRepository {
  Future<Either<Failure, QueueStatus>> getQueueStatus(String appointmentId);
  Future<Either<Failure, void>> cancelQueuePosition(String appointmentId);
}
