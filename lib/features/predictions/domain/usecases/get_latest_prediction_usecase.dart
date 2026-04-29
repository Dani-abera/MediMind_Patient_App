import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction.dart';
import '../repositories/predictions_repository.dart';

class GetLatestPredictionUsecase {
  const GetLatestPredictionUsecase(this._repository);
  final PredictionsRepository _repository;

  Future<Either<Failure, Prediction?>> call() =>
      _repository.getLatestPrediction();
}
