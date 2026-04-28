import 'package:equatable/equatable.dart';
import '../../../domain/entities/time_slot.dart';

abstract class SlotPickerEvent extends Equatable {
  const SlotPickerEvent();
  @override
  List<Object?> get props => [];
}

class SlotPickerInitialized extends SlotPickerEvent {
  const SlotPickerInitialized({
    required this.doctorId,
    required this.centerId,
  });
  final String doctorId;
  final String centerId;
  @override
  List<Object?> get props => [doctorId, centerId];
}

class SlotDateSelected extends SlotPickerEvent {
  const SlotDateSelected(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class SlotChipSelected extends SlotPickerEvent {
  const SlotChipSelected(this.slot);
  final TimeSlot slot;
  @override
  List<Object?> get props => [slot];
}
