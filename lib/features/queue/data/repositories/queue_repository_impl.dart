import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl(this._dataSource);
  final QueueRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, QueueStatus>> getQueueStatus(
      String appointmentId) async {
    try {
      return Right(await _dataSource.getQueueStatus(appointmentId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelQueuePosition(
      String appointmentId) async {
    try {
      await _dataSource.cancelQueuePosition(appointmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
