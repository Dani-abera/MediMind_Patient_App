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
        id: (json['recordId'] ?? json['_id'] ?? json['id'] ?? '') as String,
        recordedAt: _parseRecordedAt(json),
        bloodPressureSystolic:
            (json['bloodPressureSystolic'] ?? json['systolicBp'] as num?)
                ?.toDouble(),
        bloodPressureDiastolic:
            (json['bloodPressureDiastolic'] ?? json['diastolicBp'] as num?)
                ?.toDouble(),
        glucoseLevel: (json['glucoseLevel'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        heartRate: (json['heartRate'] as num?)?.toDouble(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
        respiratoryRate: (json['respiratoryRate'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  // The backend returns recordDate + recordTime separately, or createdAt.
  static DateTime _parseRecordedAt(Map<String, dynamic> json) {
    final raw = json['recordedAt'] as String?;
    if (raw != null) return DateTime.parse(raw);

    final createdAt = json['createdAt'] as String?;
    if (createdAt != null) return DateTime.parse(createdAt);

    final dateStr = json['recordDate'] as String?;
    final timeStr = json['recordTime'] as String?;
    if (dateStr != null && timeStr != null) {
      return DateTime.tryParse('${dateStr}T$timeStr') ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final d = recordedAt;
    final dateStr =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      'recordDate': dateStr,
      if (bloodPressureSystolic != null)
        'systolicBp': bloodPressureSystolic!.round(),
      if (bloodPressureDiastolic != null)
        'diastolicBp': bloodPressureDiastolic!.round(),
      if (glucoseLevel != null) 'glucoseLevel': glucoseLevel,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (heartRate != null) 'heartRate': heartRate!.round(),
      if (temperature != null) 'temperature': temperature,
      if (oxygenSaturation != null)
        'oxygenSaturation': oxygenSaturation!.round(),
      if (respiratoryRate != null) 'respiratoryRate': respiratoryRate!.round(),
      if (notes != null) 'notes': notes,
    };
  }
}
