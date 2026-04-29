import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_record.dart';
import '../repositories/health_records_repository.dart';

class GetHealthRecordsUsecase {
  const GetHealthRecordsUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, List<HealthRecord>>> call({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.getHealthRecords(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );
}
