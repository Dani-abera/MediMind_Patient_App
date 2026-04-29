import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_history.dart';

abstract class MedicalHistoryRepository {
  Future<Either<Failure, MedicalHistory>> getMedicalHistory();
  Future<Either<Failure, MedicalHistory>> updateMedicalHistory(MedicalHistory history);
}
