import '../../domain/entities/health_record.dart';

class HealthRecordModel extends HealthRecord {
  const HealthRecordModel({
    required super.id,
    required super.recordedAt,
    super.bloodPressureSystolic,
    super.bloodPressureDiastolic,
    super.glucoseLevel,
    super.weight,
    super.height,
    super.heartRate,
    super.temperature,
    super.oxygenSaturation,
    super.respiratoryRate,
    super.notes,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) =>
      HealthRecordModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        bloodPressureSystolic:
            (json['bloodPressureSystolic'] as num?)?.toDouble(),
        bloodPressureDiastolic:
            (json['bloodPressureDiastolic'] as num?)?.toDouble(),
        glucoseLevel: (json['glucoseLevel'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        heartRate: (json['heartRate'] as num?)?.toDouble(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
        respiratoryRate: (json['respiratoryRate'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (bloodPressureSystolic != null)
          'bloodPressureSystolic': bloodPressureSystolic,
        if (bloodPressureDiastolic != null)
          'bloodPressureDiastolic': bloodPressureDiastolic,
        if (glucoseLevel != null) 'glucoseLevel': glucoseLevel,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (heartRate != null) 'heartRate': heartRate,
        if (temperature != null) 'temperature': temperature,
        if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
        if (respiratoryRate != null) 'respiratoryRate': respiratoryRate,
        if (notes != null) 'notes': notes,
      };
}
