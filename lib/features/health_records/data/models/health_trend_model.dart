import 'package:flutter/foundation.dart';
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
      metric: json['metric'] as String? ?? '',
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
    debugPrint('[TrendsModel] response keys: ${json.keys.toList()}');

    // ── New rich format ─────────────────────────────────────────────────────
    // Backend returns per-metric nested objects with a "points" time-series.
    if (json.containsKey('bloodPressureSystolic') ||
        json.containsKey('glucoseLevel') ||
        json.containsKey('heartRate') ||
        json.containsKey('oxygenSaturation')) {
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

    // ── Legacy flat format ───────────────────────────────────────────────────
    // Older backend returns a single flat aggregate:
    //   { "averageSystolicBp": 139.1, "trendDirection": "Worsening", ... }
    // Build synthetic HealthTrendModel objects (no time-series points).
    debugPrint('[TrendsModel] Detected legacy flat format — restart the backend '
        'to get per-metric data with chart points.');

    final rawDir =
        (json['trendDirection'] as String? ?? 'stable').toLowerCase();
    // Map backend direction labels → Flutter arrow labels
    final direction = rawDir == 'worsening'
        ? 'increasing'
        : rawDir == 'improving'
            ? 'decreasing'
            : 'stable';

    HealthTrendModel? flat(
      String metric,
      String unit,
      num? average,
      num? minimum,
      num? maximum,
      double? normalMin,
      double? normalMax,
    ) {
      if (average == null) return null;
      final avg = average.toDouble();
      return HealthTrendModel(
        metric: metric,
        unit: unit,
        points: const <TrendPoint>[],
        average: avg,
        minimum: minimum?.toDouble() ?? avg,
        maximum: maximum?.toDouble() ?? avg,
        trendDirection: direction,
        normalMin: normalMin,
        normalMax: normalMax,
      );
    }

    return HealthTrendsDataModel(
      systolic: flat(
        'Systolic BP', 'mmHg',
        json['averageSystolicBp'] as num?,
        json['minSystolicBp'] as num?,
        json['maxSystolicBp'] as num?,
        90, 120,
      ),
      diastolic: flat(
        'Diastolic BP', 'mmHg',
        json['averageDiastolicBp'] as num?,
        null, null, 60, 80,
      ),
      glucose: flat(
        'Blood Glucose', 'mg/dL',
        json['averageGlucose'] as num?,
        null, null, 70, 100,
      ),
      weight: flat(
        'Weight', 'kg',
        json['averageWeight'] as num?,
        null, null, null, null,
      ),
      overallInsight: rawDir.isNotEmpty
          ? 'Overall blood pressure trend: ${json['trendDirection']}'
          : null,
    );
  }
}
