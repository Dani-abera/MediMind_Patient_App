import 'package:equatable/equatable.dart';
import '../../../domain/entities/time_slot.dart';

abstract class SlotPickerState extends Equatable {
  const SlotPickerState();
  @override
  List<Object?> get props => [];
}

class SlotPickerInitial extends SlotPickerState {
  const SlotPickerInitial();
}

class DatesLoading extends SlotPickerState {
  const DatesLoading();
}

class DatesLoaded extends SlotPickerState {
  const DatesLoaded({
    required this.availableDates,
    this.selectedDate,
    required this.doctorId,
    required this.centerId,
  });

  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final String doctorId;
  final String centerId;

  @override
  List<Object?> get props => [availableDates, selectedDate, doctorId, centerId];
}

class SlotsLoading extends SlotPickerState {
  const SlotsLoading({
    required this.availableDates,
    required this.selectedDate,
    required this.doctorId,
    required this.centerId,
  });

  final List<DateTime> availableDates;
  final DateTime selectedDate;
  final String doctorId;
  final String centerId;

  @override
  List<Object?> get props =>
      [availableDates, selectedDate, doctorId, centerId];
}

class SlotsLoaded extends SlotPickerState {
  const SlotsLoaded({
    required this.availableDates,
    required this.selectedDate,
    required this.slots,
    required this.doctorId,
    required this.centerId,
    this.selectedSlot,
  });

  final List<DateTime> availableDates;
  final DateTime selectedDate;
  final List<TimeSlot> slots;
  final String doctorId;
  final String centerId;
  final TimeSlot? selectedSlot;

  SlotsLoaded withSelectedSlot(TimeSlot slot) => SlotsLoaded(
        availableDates: availableDates,
        selectedDate: selectedDate,
        slots: slots,
        doctorId: doctorId,
        centerId: centerId,
        selectedSlot: slot,
      );

  @override
  List<Object?> get props => [
        availableDates, selectedDate, slots, doctorId, centerId, selectedSlot,
      ];
}

class SlotsError extends SlotPickerState {
  const SlotsError({
    required this.message,
    required this.availableDates,
    required this.selectedDate,
    required this.doctorId,
    required this.centerId,
  });

  final String message;
  final List<DateTime> availableDates;
  final DateTime selectedDate;
  final String doctorId;
  final String centerId;

  @override
  List<Object?> get props => [message, availableDates, selectedDate];
}
