import 'package:equatable/equatable.dart';

abstract class TrendsEvent extends Equatable {
  const TrendsEvent();
  @override
  List<Object?> get props => [];
}

class TrendsRequested extends TrendsEvent {
  const TrendsRequested({this.days = 30});
  final int days;
  @override
  List<Object?> get props => [days];
}

class TrendsPeriodChanged extends TrendsEvent {
  const TrendsPeriodChanged(this.days);
  final int days;
  @override
  List<Object?> get props => [days];
}
