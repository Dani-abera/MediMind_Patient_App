import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_record.dart';
import '../repositories/health_records_repository.dart';

class GetLatestRecordUsecase {
  const GetLatestRecordUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, HealthRecord?>> call() =>
      _repository.getLatestRecord();
}
