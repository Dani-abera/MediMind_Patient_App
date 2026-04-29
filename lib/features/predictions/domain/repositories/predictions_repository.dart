import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction.dart';

abstract class PredictionsRepository {
  Future<Either<Failure, Prediction>> requestPrediction();
  Future<Either<Failure, List<Prediction>>> getPredictions();
  Future<Either<Failure, Prediction?>> getLatestPrediction();
  Future<Either<Failure, Prediction>> getPredictionById(String id);
}
