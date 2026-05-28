import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_status.dart';
import '../repositories/predictions_repository.dart';

class GetPredictionStatusUsecase {
  const GetPredictionStatusUsecase(this._repository);
  final PredictionsRepository _repository;

  Future<Either<Failure, PredictionStatus>> call() =>
      _repository.getPredictionStatus();
}
