import 'package:equatable/equatable.dart';

enum VitalStatus { normal, watch, alert }

class HealthRecord extends Equatable {
  const HealthRecord({
    required this.id,
    required this.recordedAt,
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
  });

  final String id;
  final DateTime recordedAt;
  final double? bloodPressureSystolic;   // mmHg
  final double? bloodPressureDiastolic;  // mmHg
  final double? glucoseLevel;            // mg/dL
  final double? weight;                  // kg
  final double? height;                  // cm
  final double? heartRate;               // bpm
  final double? temperature;             // °C
  final double? oxygenSaturation;        // %
  final double? respiratoryRate;         // per min
  final String? notes;

  bool get isToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }

  double? get calculatedBmi =>
      (weight != null && height != null && height! > 0)
          ? weight! / ((height! / 100) * (height! / 100))
          : null;

  bool get hasAnyData =>
      bloodPressureSystolic != null ||
      glucoseLevel != null ||
      weight != null ||
      heartRate != null ||
      temperature != null ||
      oxygenSaturation != null;

  VitalStatus get bpStatus {
    final s = bloodPressureSystolic;
    if (s == null) return VitalStatus.normal;
    if (s < 120) return VitalStatus.normal;
    if (s < 140) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  VitalStatus get glucoseStatus {
    final g = glucoseLevel;
    if (g == null) return VitalStatus.normal;
    if (g >= 70 && g <= 140) return VitalStatus.normal;
    if (g < 200) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  VitalStatus get heartRateStatus {
    final h = heartRate;
    if (h == null) return VitalStatus.normal;
    if (h >= 60 && h <= 100) return VitalStatus.normal;
    if (h >= 50 && h <= 120) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  VitalStatus get oxygenStatus {
    final o = oxygenSaturation;
    if (o == null) return VitalStatus.normal;
    if (o >= 95) return VitalStatus.normal;
    if (o >= 90) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  VitalStatus get tempStatus {
    final t = temperature;
    if (t == null) return VitalStatus.normal;
    if (t >= 36.1 && t <= 37.2) return VitalStatus.normal;
    if (t <= 38.0) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  @override
  List<Object?> get props => [
        id,
        recordedAt,
        bloodPressureSystolic,
        bloodPressureDiastolic,
        glucoseLevel,
        weight,
        height,
        heartRate,
        temperature,
        oxygenSaturation,
        respiratoryRate,
        notes,
      ];
}
