import 'package:equatable/equatable.dart';

class TrendPoint extends Equatable {
  const TrendPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
  @override
  List<Object?> get props => [date, value];
}

class HealthTrend extends Equatable {
  const HealthTrend({
    required this.metric,
    required this.unit,
    required this.points,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.trendDirection,
    this.normalMin,
    this.normalMax,
    this.insight,
  });

  final String metric;          // e.g. 'bloodPressureSystolic'
  final String unit;
  final List<TrendPoint> points;
  final double average;
  final double minimum;
  final double maximum;
  final String trendDirection;  // 'increasing' | 'decreasing' | 'stable'
  final double? normalMin;
  final double? normalMax;
  final String? insight;

  double get standardDeviation {
    if (points.isEmpty) return 0;
    final mean = average;
    final variance = points
            .map((p) => (p.value - mean) * (p.value - mean))
            .fold(0.0, (a, b) => a + b) /
        points.length;
    return variance > 0 ? _sqrt(variance) : 0;
  }

  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 50; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }

  @override
  List<Object?> get props =>
      [metric, unit, points, average, minimum, maximum, trendDirection];
}

// All trend data for all metrics from one API call
class HealthTrendsData extends Equatable {
  const HealthTrendsData({
    this.systolic,
    this.diastolic,
    this.glucose,
    this.weight,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.overallInsight,
  });

  final HealthTrend? systolic;
  final HealthTrend? diastolic;
  final HealthTrend? glucose;
  final HealthTrend? weight;
  final HealthTrend? heartRate;
  final HealthTrend? temperature;
  final HealthTrend? oxygenSaturation;
  final String? overallInsight;

  HealthTrend? forMetric(String metric) => switch (metric) {
        'bloodPressureSystolic' => systolic,
        'bloodPressureDiastolic' => diastolic,
        'glucose' => glucose,
        'weight' => weight,
        'heartRate' => heartRate,
        'temperature' => temperature,
        'oxygenSaturation' => oxygenSaturation,
        _ => null,
      };

  @override
  List<Object?> get props => [
        systolic,
        diastolic,
        glucose,
        weight,
        heartRate,
        temperature,
        oxygenSaturation,
      ];
}
