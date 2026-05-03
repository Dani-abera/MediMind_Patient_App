import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/health_trend.dart';
import '../../domain/entities/record_count.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../datasources/health_records_remote_datasource.dart';
import '../models/health_record_model.dart';

class HealthRecordsRepositoryImpl implements HealthRecordsRepository {
  const HealthRecordsRepositoryImpl(this._remote);
  final HealthRecordsRemoteDataSource _remote;

  @override
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
  }) =>
      _wrap(() => _remote.logVitals(
            HealthRecordModel(
              id: '',
              recordedAt: DateTime.now(),
              bloodPressureSystolic: bloodPressureSystolic,
              bloodPressureDiastolic: bloodPressureDiastolic,
              glucoseLevel: glucoseLevel,
              weight: weight,
              height: height,
              heartRate: heartRate,
              temperature: temperature,
              oxygenSaturation: oxygenSaturation,
              respiratoryRate: respiratoryRate,
              notes: notes,
            ).toJson(),
          ));

  @override
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
  }) =>
      _wrap(() => _remote.updateRecord(
            id,
            HealthRecordModel(
              id: id,
              recordedAt: DateTime.now(),
              bloodPressureSystolic: bloodPressureSystolic,
              bloodPressureDiastolic: bloodPressureDiastolic,
              glucoseLevel: glucoseLevel,
              weight: weight,
              height: height,
              heartRate: heartRate,
              temperature: temperature,
              oxygenSaturation: oxygenSaturation,
              respiratoryRate: respiratoryRate,
              notes: notes,
            ).toJson(),
          ));

  @override
  Future<Either<Failure, List<HealthRecord>>> getHealthRecords({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) =>
      _wrapList(() => _remote.getHealthRecords(
            startDate: startDate,
            endDate: endDate,
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, HealthRecord?>> getLatestRecord() async {
    try {
      return Right(await _remote.getLatestRecord());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String id) async {
    try {
      await _remote.deleteRecord(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthTrendsData>> getTrends({int days = 30}) =>
      _wrap(() => _remote.getTrends(days: days));

  @override
  Future<Either<Failure, RecordCount>> getRecordCount() =>
      _wrap(() => _remote.getRecordCount());

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<T>>> _wrapList<T>(
      Future<List<T>> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
