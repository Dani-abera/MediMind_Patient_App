import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/record_count.dart';
import '../repositories/health_records_repository.dart';

class GetRecordCountUsecase {
  const GetRecordCountUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, RecordCount>> call() => _repository.getRecordCount();
}
