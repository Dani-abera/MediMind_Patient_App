import 'package:equatable/equatable.dart';

enum RiskLevel { low, medium, high }

class DiseaseRisk extends Equatable {
  const DiseaseRisk({
    required this.riskScore,
    required this.riskLevel,
    this.contributingFactors = const [],
  });

  final double riskScore;              // 0–100
  final RiskLevel riskLevel;
  final List<String> contributingFactors;

  String get riskLabel => switch (riskLevel) {
        RiskLevel.low => 'Low',
        RiskLevel.medium => 'Medium',
        RiskLevel.high => 'High',
      };

  @override
  List<Object?> get props => [riskScore, riskLevel];
}

class Prediction extends Equatable {
  const Prediction({
    required this.id,
    required this.createdAt,
    required this.dataPointsUsed,
    required this.confidenceLevel,
    required this.diabetes,
    required this.hypertension,
    required this.cardiovascular,
    this.recommendations,
    this.modelVersion,
  });

  final String id;
  final DateTime createdAt;
  final int dataPointsUsed;
  final String confidenceLevel;   // 'low' | 'medium' | 'high'
  final DiseaseRisk diabetes;
  final DiseaseRisk hypertension;
  final DiseaseRisk cardiovascular;
  final String? recommendations;
  final String? modelVersion;

  String get formattedConfidence => switch (confidenceLevel) {
        'low' => 'Low confidence',
        'medium' => 'Medium confidence',
        'high' => 'High confidence',
        _ => '$dataPointsUsed data points',
      };

  static RiskLevel levelFromScore(double score) {
    if (score <= 33) return RiskLevel.low;
    if (score <= 66) return RiskLevel.medium;
    return RiskLevel.high;
  }

  @override
  List<Object?> get props => [id, createdAt, dataPointsUsed, confidenceLevel];
}
