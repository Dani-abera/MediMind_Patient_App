import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction.dart';
import '../repositories/predictions_repository.dart';

class GetPredictionsUsecase {
  const GetPredictionsUsecase(this._repository);
  final PredictionsRepository _repository;

  Future<Either<Failure, List<Prediction>>> call() =>
      _repository.getPredictions();
}
