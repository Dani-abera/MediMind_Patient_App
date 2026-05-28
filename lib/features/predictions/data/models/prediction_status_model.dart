import '../../domain/entities/prediction_status.dart';

class PredictionStatusModel extends PredictionStatus {
  const PredictionStatusModel({
    required super.canRequest,
    required super.healthRecordCount,
    required super.confidenceLevel,
    required super.message,
  });

  factory PredictionStatusModel.fromJson(Map<String, dynamic> json) {
    return PredictionStatusModel(
      canRequest: json['canRequest'] as bool? ?? false,
      healthRecordCount: json['healthRecordCount'] as int? ?? 0,
      confidenceLevel: json['confidenceLevel'] as String? ?? 'Low',
      message: json['message'] as String? ?? '',
    );
  }
}
