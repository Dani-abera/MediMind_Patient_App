import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_history.dart';
import '../repositories/medical_history_repository.dart';

class UpdateMedicalHistoryUsecase {
  UpdateMedicalHistoryUsecase(this._repository);
  final MedicalHistoryRepository _repository;

  Future<Either<Failure, MedicalHistory>> call(MedicalHistory history) =>
      _repository.updateMedicalHistory(history);
}
