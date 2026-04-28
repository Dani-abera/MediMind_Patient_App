import 'package:equatable/equatable.dart';
import '../../../../centers/domain/entities/center.dart';
import '../../../../doctors/domain/entities/doctor.dart';
import '../../../domain/entities/time_slot.dart';

abstract class BookingFlowEvent extends Equatable {
  const BookingFlowEvent();
  @override
  List<Object?> get props => [];
}

class CenterSelected extends BookingFlowEvent {
  const CenterSelected(this.center);
  final Center center;
  @override
  List<Object?> get props => [center];
}

class DoctorSelected extends BookingFlowEvent {
  const DoctorSelected(this.doctor);
  final Doctor doctor;
  @override
  List<Object?> get props => [doctor];
}

class SlotSelected extends BookingFlowEvent {
  const SlotSelected({required this.date, required this.slot});
  final DateTime date;
  final TimeSlot slot;
  @override
  List<Object?> get props => [date, slot];
}

class ReasonEntered extends BookingFlowEvent {
  const ReasonEntered({required this.reason, this.symptoms});
  final String reason;
  final String? symptoms;
  @override
  List<Object?> get props => [reason, symptoms];
}

class TermsToggled extends BookingFlowEvent {
  const TermsToggled();
}

class BookingConfirmed extends BookingFlowEvent {
  const BookingConfirmed();
}

class PaymentCompleted extends BookingFlowEvent {
  const PaymentCompleted();
}

class BookingReset extends BookingFlowEvent {
  const BookingReset();
}
