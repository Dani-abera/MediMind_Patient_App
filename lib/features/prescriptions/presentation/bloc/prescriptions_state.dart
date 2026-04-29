import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription.dart';

abstract class PrescriptionsState extends Equatable {
  const PrescriptionsState();
  @override List<Object?> get props => [];
}

class PrescriptionsInitial extends PrescriptionsState {
  const PrescriptionsInitial();
}

class PrescriptionsLoading extends PrescriptionsState {
  const PrescriptionsLoading();
}

class PrescriptionsLoaded extends PrescriptionsState {
  const PrescriptionsLoaded(this.prescriptions);
  final List<Prescription> prescriptions;
  @override List<Object?> get props => [prescriptions];
}

class PrescriptionDetailLoaded extends PrescriptionsState {
  const PrescriptionDetailLoaded(this.prescription);
  final Prescription prescription;
  @override List<Object?> get props => [prescription];
}

class PrescriptionsFailure extends PrescriptionsState {
  const PrescriptionsFailure(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
