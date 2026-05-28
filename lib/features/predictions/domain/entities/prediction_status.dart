import 'package:equatable/equatable.dart';

class PredictionStatus extends Equatable {
  const PredictionStatus({
    required this.canRequest,
    required this.healthRecordCount,
    required this.confidenceLevel,
    required this.message,
  });

  final bool canRequest;
  final int healthRecordCount;
  final String confidenceLevel; // 'Low' | 'Medium' | 'High'
  final String message;

  @override
  List<Object?> get props =>
      [canRequest, healthRecordCount, confidenceLevel, message];
}
