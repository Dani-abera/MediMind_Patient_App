import 'package:equatable/equatable.dart';
import '../../../domain/entities/prediction.dart';

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
  });
  final List<Prediction> predictions;
  final Prediction? latestPrediction;
  @override
  List<Object?> get props => [predictions, latestPrediction];
}

// Shown while the AI model is processing
class PredictionProcessing extends PredictionState {
  const PredictionProcessing();
}

// Insufficient data to generate a meaningful prediction
class PredictionInsufficientData extends PredictionState {
  const PredictionInsufficientData({required this.dataPointsUsed});
  final int dataPointsUsed;
  @override
  List<Object?> get props => [dataPointsUsed];
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
