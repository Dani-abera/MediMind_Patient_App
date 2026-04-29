import '../../domain/entities/health_trend.dart';

class TrendPointModel extends TrendPoint {
  const TrendPointModel({required super.date, required super.value});

  factory TrendPointModel.fromJson(Map<String, dynamic> json) =>
      TrendPointModel(
        date: DateTime.parse(json['date'] as String),
        value: (json['value'] as num).toDouble(),
      );
}

class HealthTrendModel extends HealthTrend {
  const HealthTrendModel({
    required super.metric,
    required super.unit,
    required super.points,
    required super.average,
    required super.minimum,
    required super.maximum,
    required super.trendDirection,
    super.normalMin,
    super.normalMax,
    super.insight,
  });

  factory HealthTrendModel.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List<dynamic>? ?? [])
        .map((p) => TrendPointModel.fromJson(p as Map<String, dynamic>))
        .toList();
    return HealthTrendModel(
      metric: json['metric'] as String,
      unit: json['unit'] as String? ?? '',
      points: pts,
      average: (json['average'] as num).toDouble(),
      minimum: (json['minimum'] as num).toDouble(),
      maximum: (json['maximum'] as num).toDouble(),
      trendDirection: json['trendDirection'] as String? ?? 'stable',
      normalMin: (json['normalMin'] as num?)?.toDouble(),
      normalMax: (json['normalMax'] as num?)?.toDouble(),
      insight: json['insight'] as String?,
    );
  }
}

class HealthTrendsDataModel extends HealthTrendsData {
  const HealthTrendsDataModel({
    super.systolic,
    super.diastolic,
    super.glucose,
    super.weight,
    super.heartRate,
    super.temperature,
    super.oxygenSaturation,
    super.overallInsight,
  });

  factory HealthTrendsDataModel.fromJson(Map<String, dynamic> json) {
    HealthTrendModel? parseTrend(String key) {
      final raw = json[key];
      if (raw == null) return null;
      return HealthTrendModel.fromJson(raw as Map<String, dynamic>);
    }

    return HealthTrendsDataModel(
      systolic: parseTrend('bloodPressureSystolic'),
      diastolic: parseTrend('bloodPressureDiastolic'),
      glucose: parseTrend('glucoseLevel'),
      weight: parseTrend('weight'),
      heartRate: parseTrend('heartRate'),
      temperature: parseTrend('temperature'),
      oxygenSaturation: parseTrend('oxygenSaturation'),
      overallInsight: json['overallInsight'] as String?,
    );
  }
}
