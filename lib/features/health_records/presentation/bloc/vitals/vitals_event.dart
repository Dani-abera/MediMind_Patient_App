import 'package:equatable/equatable.dart';

abstract class VitalsEvent extends Equatable {
  const VitalsEvent();
  @override
  List<Object?> get props => [];
}

class VitalsRequested extends VitalsEvent {
  const VitalsRequested({this.startDate, this.endDate});
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  List<Object?> get props => [startDate, endDate];
}

class VitalsRefreshed extends VitalsEvent {
  const VitalsRefreshed();
}

class VitalRecordDeleted extends VitalsEvent {
  const VitalRecordDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
