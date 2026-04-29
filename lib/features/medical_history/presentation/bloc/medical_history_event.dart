import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_history.dart';

abstract class MedicalHistoryEvent extends Equatable {
  const MedicalHistoryEvent();
  @override List<Object?> get props => [];
}

class MedicalHistoryRequested extends MedicalHistoryEvent {
  const MedicalHistoryRequested();
}

class MedicalHistoryUpdated extends MedicalHistoryEvent {
  const MedicalHistoryUpdated(this.history);
  final MedicalHistory history;
  @override List<Object?> get props => [history];
}
