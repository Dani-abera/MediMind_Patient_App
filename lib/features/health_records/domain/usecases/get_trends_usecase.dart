import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_trend.dart';
import '../repositories/health_records_repository.dart';

class GetTrendsUsecase {
  const GetTrendsUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, HealthTrendsData>> call({int days = 30}) =>
      _repository.getTrends(days: days);
}
