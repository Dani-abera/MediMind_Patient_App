import '../../domain/entities/prediction.dart';

class DiseaseRiskModel extends DiseaseRisk {
  const DiseaseRiskModel({
    required super.riskScore,
    required super.riskLevel,
    super.contributingFactors,
  });

  factory DiseaseRiskModel.fromBackend({
    required double riskScore,
    required String category,
    required List<String> factors,
  }) {
    return DiseaseRiskModel(
      riskScore: riskScore,
      riskLevel: _levelFromCategory(category),
      contributingFactors: factors,
    );
  }

  static RiskLevel _levelFromCategory(String category) {
    return switch (category.toLowerCase()) {
      'low' => RiskLevel.low,
      'medium' || 'moderate' => RiskLevel.medium,
      'high' => RiskLevel.high,
      _ => RiskLevel.low,
    };
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

    final factors = (json['contributingFactors'] as Map<String, dynamic>?) ?? {};
    List<String> extractFactors(String key) =>
        (factors[key] as List<dynamic>? ?? []).map((f) => f as String).toList();

    // "Low Confidence" / "Medium Confidence" / "High Confidence" → 'low'/'medium'/'high'
    // Falls back to deriving from dataPointsUsed for summary DTOs that omit this field.
    final desc = (json['confidenceLevelDescription'] as String? ?? '').toLowerCase();
    final confidenceLevel = desc.contains('high')
        ? 'high'
        : desc.contains('medium')
            ? 'medium'
            : desc.contains('low')
                ? 'low'
                : dataPoints >= 30
                    ? 'high'
                    : dataPoints >= 7
                        ? 'medium'
                        : 'low';

    return PredictionModel(
      id: (json['predictionId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dataPointsUsed: dataPoints,
      confidenceLevel: confidenceLevel,
      diabetes: DiseaseRiskModel.fromBackend(
        riskScore: (json['diabetesRisk'] as num? ?? 0).toDouble(),
        category: json['diabetesCategory'] as String? ?? 'Low',
        factors: extractFactors('Diabetes'),
      ),
      hypertension: DiseaseRiskModel.fromBackend(
        riskScore: (json['hypertensionRisk'] as num? ?? 0).toDouble(),
        category: json['hypertensionCategory'] as String? ?? 'Low',
        factors: extractFactors('Hypertension'),
      ),
      cardiovascular: DiseaseRiskModel.fromBackend(
        riskScore: (json['cvdRisk'] as num? ?? 0).toDouble(),
        category: json['cvdCategory'] as String? ?? 'Low',
        factors: extractFactors('Cardiovascular'),
      ),
      recommendations: json['recommendations'] as String?,
      modelVersion: json['modelVersion'] as String?,
    );
  }
}
