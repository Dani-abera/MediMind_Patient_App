import 'package:equatable/equatable.dart';
import '../../../domain/entities/prediction.dart';
import '../../../domain/entities/prediction_status.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();
  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {
  const PredictionInitial();
}

class PredictionsLoading extends PredictionState {
  const PredictionsLoading();
}

class PredictionsLoaded extends PredictionState {
  const PredictionsLoaded({
    required this.predictions,
    this.latestPrediction,
    this.status,
  });
  final List<Prediction> predictions;
  final Prediction? latestPrediction;
  final PredictionStatus? status;
  @override
  List<Object?> get props => [predictions, latestPrediction, status];
}

// Shown while the AI model is processing
class PredictionProcessing extends PredictionState {
  const PredictionProcessing();
}

// Insufficient data to generate a meaningful prediction
class PredictionInsufficientData extends PredictionState {
  const PredictionInsufficientData({
    required this.dataPointsUsed,
    required this.canRequestPrediction,
    this.message,
  });
  final int dataPointsUsed;
  final bool canRequestPrediction;
  final String? message;
  @override
  List<Object?> get props => [dataPointsUsed, canRequestPrediction, message];
}

class PredictionStatusLoaded extends PredictionState {
  const PredictionStatusLoaded(this.status);
  final PredictionStatus status;
  @override
  List<Object?> get props => [status];
}

class PredictionSuccess extends PredictionState {
  const PredictionSuccess(this.prediction);
  final Prediction prediction;
  @override
  List<Object?> get props => [prediction];
}

class PredictionDetailLoaded extends PredictionState {
  const PredictionDetailLoaded(this.prediction);
  final Prediction prediction;
  @override
  List<Object?> get props => [prediction];
}

class PredictionFailure extends PredictionState {
  const PredictionFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
