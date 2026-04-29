import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_record.dart';
import '../repositories/health_records_repository.dart';

class LogVitalsParams extends Equatable {
  const LogVitalsParams({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.glucoseLevel,
    this.weight,
    this.height,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.notes,
    this.recordId,
  });

  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? glucoseLevel;
  final double? weight;
  final double? height;
  final double? heartRate;
  final double? temperature;
  final double? oxygenSaturation;
  final double? respiratoryRate;
  final String? notes;
  final String? recordId;  // non-null when updating existing record

  @override
  List<Object?> get props => [recordId];
}

class LogVitalsUsecase {
  const LogVitalsUsecase(this._repository);
  final HealthRecordsRepository _repository;

  Future<Either<Failure, HealthRecord>> call(LogVitalsParams p) =>
      p.recordId != null
          ? _repository.updateRecord(
              id: p.recordId!,
              bloodPressureSystolic: p.bloodPressureSystolic,
              bloodPressureDiastolic: p.bloodPressureDiastolic,
              glucoseLevel: p.glucoseLevel,
              weight: p.weight,
              height: p.height,
              heartRate: p.heartRate,
              temperature: p.temperature,
              oxygenSaturation: p.oxygenSaturation,
              respiratoryRate: p.respiratoryRate,
              notes: p.notes,
            )
          : _repository.logVitals(
              bloodPressureSystolic: p.bloodPressureSystolic,
              bloodPressureDiastolic: p.bloodPressureDiastolic,
              glucoseLevel: p.glucoseLevel,
              weight: p.weight,
              height: p.height,
              heartRate: p.heartRate,
              temperature: p.temperature,
              oxygenSaturation: p.oxygenSaturation,
              respiratoryRate: p.respiratoryRate,
              notes: p.notes,
            );
}
