import 'package:equatable/equatable.dart';
import '../../../domain/entities/health_record.dart';

abstract class VitalsState extends Equatable {
  const VitalsState();
  @override
  List<Object?> get props => [];
}

class VitalsInitial extends VitalsState {
  const VitalsInitial();
}

class VitalsLoading extends VitalsState {
  const VitalsLoading();
}

class VitalsLoaded extends VitalsState {
  const VitalsLoaded({
    required this.records,
    required this.totalCount,
    this.latestRecord,
  });
  final List<HealthRecord> records;
  final int totalCount;
  final HealthRecord? latestRecord;
  @override
  List<Object?> get props => [records, totalCount, latestRecord];
}

class VitalsFailure extends VitalsState {
  const VitalsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
