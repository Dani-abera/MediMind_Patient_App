import 'package:equatable/equatable.dart';
import '../../../domain/entities/health_trend.dart';

abstract class TrendsState extends Equatable {
  const TrendsState();
  @override
  List<Object?> get props => [];
}

class TrendsInitial extends TrendsState {
  const TrendsInitial();
}

class TrendsLoading extends TrendsState {
  const TrendsLoading();
}

class TrendsLoaded extends TrendsState {
  const TrendsLoaded({required this.data, required this.days});
  final HealthTrendsData data;
  final int days;
  @override
  List<Object?> get props => [data, days];
}

class TrendsFailure extends TrendsState {
  const TrendsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
