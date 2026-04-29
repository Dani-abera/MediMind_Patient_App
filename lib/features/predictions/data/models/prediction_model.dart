import '../../domain/entities/prediction.dart';

class DiseaseRiskModel extends DiseaseRisk {
  const DiseaseRiskModel({
    required super.riskScore,
    required super.riskLevel,
    super.contributingFactors,
  });

  factory DiseaseRiskModel.fromJson(Map<String, dynamic> json) {
    final score = (json['riskScore'] as num).toDouble();
    return DiseaseRiskModel(
      riskScore: score,
      riskLevel: Prediction.levelFromScore(score),
      contributingFactors: (json['contributingFactors'] as List<dynamic>? ?? [])
          .map((f) => f as String)
          .toList(),
    );
  }
}

class PredictionModel extends Prediction {
  const PredictionModel({
    required super.id,
    required super.createdAt,
    required super.dataPointsUsed,
    required super.confidenceLevel,
    required super.diabetes,
    required super.hypertension,
    required super.cardiovascular,
    super.recommendations,
    super.modelVersion,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final dataPoints = json['dataPointsUsed'] as int? ?? 0;
    final confidence = dataPoints == 0
        ? 'low'
        : dataPoints < 7
            ? 'low'
            : dataPoints < 30
                ? 'medium'
                : 'high';

    return PredictionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      dataPointsUsed: dataPoints,
      confidenceLevel: json['confidenceLevel'] as String? ?? confidence,
      diabetes: DiseaseRiskModel.fromJson(
          json['diabetes'] as Map<String, dynamic>),
      hypertension: DiseaseRiskModel.fromJson(
          json['hypertension'] as Map<String, dynamic>),
      cardiovascular: DiseaseRiskModel.fromJson(
          json['cardiovascular'] as Map<String, dynamic>),
      recommendations: json['recommendations'] as String?,
      modelVersion: json['modelVersion'] as String?,
    );
  }
}
