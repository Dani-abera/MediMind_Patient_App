import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/predictions_repository.dart';
import '../datasources/predictions_remote_datasource.dart';

class PredictionsRepositoryImpl implements PredictionsRepository {
  const PredictionsRepositoryImpl(this._remote);
  final PredictionsRemoteDataSource _remote;

  @override
  Future<Either<Failure, Prediction>> requestPrediction() =>
      _wrap(() => _remote.requestPrediction());

  @override
  Future<Either<Failure, List<Prediction>>> getPredictions() =>
      _wrapList(() => _remote.getPredictions());

  @override
  Future<Either<Failure, Prediction?>> getLatestPrediction() async {
    try {
      return Right(await _remote.getLatestPrediction());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Prediction>> getPredictionById(String id) =>
      _wrap(() => _remote.getPredictionById(id));

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
