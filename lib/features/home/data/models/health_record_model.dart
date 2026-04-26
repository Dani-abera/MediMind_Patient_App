import '../../domain/entities/health_record.dart';

class HealthRecordModel extends HealthRecord {
  const HealthRecordModel({
    required super.id,
    required super.recordedAt,
    super.bloodPressureSystolic,
    super.bloodPressureDiastolic,
    super.glucoseLevel,
    super.weight,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      bloodPressureSystolic:
          (json['bloodPressureSystolic'] as num?)?.toDouble(),
      bloodPressureDiastolic:
          (json['bloodPressureDiastolic'] as num?)?.toDouble(),
      glucoseLevel: (json['glucoseLevel'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}
