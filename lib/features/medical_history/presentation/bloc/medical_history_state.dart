import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_history.dart';

abstract class MedicalHistoryState extends Equatable {
  const MedicalHistoryState();
  @override List<Object?> get props => [];
}

class MedicalHistoryInitial extends MedicalHistoryState {
  const MedicalHistoryInitial();
}

class MedicalHistoryLoading extends MedicalHistoryState {
  const MedicalHistoryLoading();
}

class MedicalHistoryLoaded extends MedicalHistoryState {
  const MedicalHistoryLoaded(this.history);
  final MedicalHistory history;
  @override List<Object?> get props => [history];
}

class MedicalHistorySaving extends MedicalHistoryState {
  const MedicalHistorySaving(this.history);
  final MedicalHistory history;
  @override List<Object?> get props => [history];
}

class MedicalHistorySaved extends MedicalHistoryState {
  const MedicalHistorySaved(this.history);
  final MedicalHistory history;
  @override List<Object?> get props => [history];
}

class MedicalHistoryFailure extends MedicalHistoryState {
  const MedicalHistoryFailure(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
