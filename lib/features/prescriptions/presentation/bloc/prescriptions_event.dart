import 'package:equatable/equatable.dart';

abstract class PrescriptionsEvent extends Equatable {
  const PrescriptionsEvent();
  @override List<Object?> get props => [];
}

class PrescriptionsRequested extends PrescriptionsEvent {
  const PrescriptionsRequested();
}

class PrescriptionDetailRequested extends PrescriptionsEvent {
  const PrescriptionDetailRequested(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

class PrescriptionsRefreshed extends PrescriptionsEvent {
  const PrescriptionsRefreshed();
}
