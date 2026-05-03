import 'package:equatable/equatable.dart';

class RecordCount extends Equatable {
  const RecordCount({required this.count, required this.canRequestPrediction});

  final int count;
  final bool canRequestPrediction;

  @override
  List<Object?> get props => [count, canRequestPrediction];
}
