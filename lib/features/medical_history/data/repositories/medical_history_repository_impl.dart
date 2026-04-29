import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/medical_history.dart';
import '../../domain/repositories/medical_history_repository.dart';
import '../datasources/medical_history_remote_datasource.dart';
import '../models/medical_history_model.dart';

class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository {
  MedicalHistoryRepositoryImpl(this._dataSource);
  final MedicalHistoryRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, MedicalHistory>> getMedicalHistory() async {
    try { return Right(await _dataSource.getMedicalHistory()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, MedicalHistory>> updateMedicalHistory(MedicalHistory history) async {
    try {
      final model = MedicalHistoryModel(
        bloodType: history.bloodType,
        chronicConditions: history.chronicConditions,
        allergies: history.allergies,
        currentMedications: history.currentMedications,
        familyHistory: history.familyHistory,
        isSmoker: history.isSmoker,
        alcoholConsumption: history.alcoholConsumption,
      );
      return Right(await _dataSource.updateMedicalHistory(model));
    }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
}
