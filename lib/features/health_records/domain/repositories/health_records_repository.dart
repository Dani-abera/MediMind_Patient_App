import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_record.dart';
import '../entities/health_trend.dart';

abstract class HealthRecordsRepository {
  Future<Either<Failure, HealthRecord>> logVitals({
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    double? glucoseLevel,
    double? weight,
    double? height,
    double? heartRate,
    double? temperature,
    double? oxygenSaturation,
    double? respiratoryRate,
    String? notes,
  });

  Future<Either<Failure, HealthRecord>> updateRecord({
    required String id,
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    double? glucoseLevel,
    double? weight,
    double? height,
    double? heartRate,
    double? temperature,
    double? oxygenSaturation,
    double? respiratoryRate,
    String? notes,
  });

  Future<Either<Failure, List<HealthRecord>>> getHealthRecords({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, HealthRecord?>> getLatestRecord();

  Future<Either<Failure, void>> deleteRecord(String id);

  Future<Either<Failure, HealthTrendsData>> getTrends({int days = 30});

  Future<Either<Failure, int>> getRecordCount();
}
