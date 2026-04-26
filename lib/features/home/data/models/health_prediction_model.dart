import '../../domain/entities/health_prediction.dart';

class HealthPredictionModel extends HealthPrediction {
  const HealthPredictionModel({
    required super.id,
    required super.assessedAt,
    required super.diabetesRisk,
    required super.hypertensionRisk,
    required super.cardiovascularRisk,
  });

  factory HealthPredictionModel.fromJson(Map<String, dynamic> json) {
    return HealthPredictionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      assessedAt: DateTime.parse(json['assessedAt'] as String),
      diabetesRisk:
          (json['diabetesRisk'] as num?)?.toDouble() ?? 0.0,
      hypertensionRisk:
          (json['hypertensionRisk'] as num?)?.toDouble() ?? 0.0,
      cardiovascularRisk:
          (json['cardiovascularRisk'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
