import 'package:equatable/equatable.dart';

enum RiskLevel { low, moderate, high }

class HealthPrediction extends Equatable {
  const HealthPrediction({
    required this.id,
    required this.assessedAt,
    required this.diabetesRisk,
    required this.hypertensionRisk,
    required this.cardiovascularRisk,
  });

  final String id;
  final DateTime assessedAt;
  final double diabetesRisk;
  final double hypertensionRisk;
  final double cardiovascularRisk;

  RiskLevel get diabetesLevel => _level(diabetesRisk);
  RiskLevel get hypertensionLevel => _level(hypertensionRisk);
  RiskLevel get cardiovascularLevel => _level(cardiovascularRisk);

  RiskLevel _level(double risk) {
    if (risk < 0.3) return RiskLevel.low;
    if (risk < 0.6) return RiskLevel.moderate;
    return RiskLevel.high;
  }

  @override
  List<Object?> get props =>
      [id, assessedAt, diabetesRisk, hypertensionRisk, cardiovascularRisk];
}
