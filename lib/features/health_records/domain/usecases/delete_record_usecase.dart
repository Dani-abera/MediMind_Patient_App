import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_records_repository.dart';

class DeleteRecordUsecase {
  const DeleteRecordUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteRecord(id);
}
