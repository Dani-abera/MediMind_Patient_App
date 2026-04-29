import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();
  @override
  List<Object?> get props => [];
}

class PredictionsRequested extends PredictionEvent {
  const PredictionsRequested();
}

class PredictionRequested extends PredictionEvent {
  const PredictionRequested();
}

class PredictionDetailRequested extends PredictionEvent {
  const PredictionDetailRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
