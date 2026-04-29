import 'package:equatable/equatable.dart';
import '../../../domain/entities/health_record.dart';

enum VitalsFormStatus { idle, loading, success, failure }

class VitalsFormState extends Equatable {
  const VitalsFormState({
    this.status = VitalsFormStatus.idle,
    this.systolic = '',
    this.diastolic = '',
    this.glucose = '',
    this.weight = '',
    this.height = '',
    this.heartRate = '',
    this.temperature = '',
    this.oxygenSaturation = '',
    this.respiratoryRate = '',
    this.notes = '',
    this.errors = const {},
    this.savedRecord,
    this.errorMessage,
  });

  final VitalsFormStatus status;
  final String systolic;
  final String diastolic;
  final String glucose;
  final String weight;
  final String height;
  final String heartRate;
  final String temperature;
  final String oxygenSaturation;
  final String respiratoryRate;
  final String notes;
  final Map<String, String> errors;
  final HealthRecord? savedRecord;
  final String? errorMessage;

  bool get isValid => errors.isEmpty && _hasAnyInput;

  bool get _hasAnyInput =>
      systolic.isNotEmpty ||
      glucose.isNotEmpty ||
      weight.isNotEmpty ||
      heartRate.isNotEmpty ||
      temperature.isNotEmpty ||
      oxygenSaturation.isNotEmpty;

  VitalsFormState copyWith({
    VitalsFormStatus? status,
    String? systolic,
    String? diastolic,
    String? glucose,
    String? weight,
    String? height,
    String? heartRate,
    String? temperature,
    String? oxygenSaturation,
    String? respiratoryRate,
    String? notes,
    Map<String, String>? errors,
    HealthRecord? savedRecord,
    String? errorMessage,
  }) =>
      VitalsFormState(
        status: status ?? this.status,
        systolic: systolic ?? this.systolic,
        diastolic: diastolic ?? this.diastolic,
        glucose: glucose ?? this.glucose,
        weight: weight ?? this.weight,
        height: height ?? this.height,
        heartRate: heartRate ?? this.heartRate,
        temperature: temperature ?? this.temperature,
        oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
        respiratoryRate: respiratoryRate ?? this.respiratoryRate,
        notes: notes ?? this.notes,
        errors: errors ?? this.errors,
        savedRecord: savedRecord ?? this.savedRecord,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status, systolic, diastolic, glucose, weight, height,
        heartRate, temperature, oxygenSaturation, respiratoryRate,
        notes, errors, savedRecord, errorMessage,
      ];
}
