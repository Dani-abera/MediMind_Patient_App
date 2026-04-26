import 'package:equatable/equatable.dart';

class VitalMetric extends Equatable {
  const VitalMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  final String label;
  final String value;
  final String unit;
  final VitalStatus status;

  @override
  List<Object?> get props => [label, value, unit, status];
}

enum VitalStatus { normal, watch, alert }

class HealthRecord extends Equatable {
  const HealthRecord({
    required this.id,
    required this.recordedAt,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.glucoseLevel,
    this.weight,
  });

  final String id;
  final DateTime recordedAt;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? glucoseLevel;
  final double? weight;

  bool get hasVitalsToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }

  List<VitalMetric> get metrics {
    final result = <VitalMetric>[];
    if (bloodPressureSystolic != null && bloodPressureDiastolic != null) {
      result.add(VitalMetric(
        label: 'Blood Pressure',
        value:
            '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()}',
        unit: 'mmHg',
        status: _bpStatus(bloodPressureSystolic!),
      ));
    }
    if (glucoseLevel != null) {
      result.add(VitalMetric(
        label: 'Glucose',
        value: glucoseLevel!.toStringAsFixed(1),
        unit: 'mmol/L',
        status: _glucoseStatus(glucoseLevel!),
      ));
    }
    if (weight != null) {
      result.add(VitalMetric(
        label: 'Weight',
        value: weight!.toStringAsFixed(1),
        unit: 'kg',
        status: VitalStatus.normal,
      ));
    }
    return result;
  }

  VitalStatus _bpStatus(double systolic) {
    if (systolic < 120) return VitalStatus.normal;
    if (systolic < 140) return VitalStatus.watch;
    return VitalStatus.alert;
  }

  VitalStatus _glucoseStatus(double mmol) {
    if (mmol >= 4.0 && mmol <= 7.8) return VitalStatus.normal;
    if (mmol < 11.0) return VitalStatus.watch;
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
      ];
}
