import 'package:equatable/equatable.dart';

import '../../../../centers/domain/entities/center.dart';
import '../../../../doctors/domain/entities/doctor.dart';
import '../../../domain/entities/time_slot.dart';

enum BookingStep {
  selectCenter,
  selectDoctor,
  selectSlot,
  fillSummary,
  processing,
  payment,
  confirmed,
}

class BookingFlowState extends Equatable {
  const BookingFlowState({
    this.selectedCenter,
    this.selectedDoctor,
    this.selectedDate,
    this.selectedSlot,
    this.reasonForVisit,
    this.symptoms,
    this.agreedToTerms = false,
    this.isProcessing = false,
    this.createdAppointmentId,
    this.paymentId,
    this.checkoutUrl,
    this.txRef,
    this.serverTotalAmount,
    this.patientEmail,
    this.patientPhone,
    this.patientFirstName,
    this.patientLastName,
    this.error,
    this.step = BookingStep.selectCenter,
  });

  final Center? selectedCenter;
  final Doctor? selectedDoctor;
  final DateTime? selectedDate;
  final TimeSlot? selectedSlot;
  final String? reasonForVisit;
  final String? symptoms;
  final bool agreedToTerms;
  final bool isProcessing;
  final String? createdAppointmentId;
  final String? paymentId;
  final String? checkoutUrl;
  final String? txRef;
  final double? serverTotalAmount;
  final String? patientEmail;
  final String? patientPhone;
  final String? patientFirstName;
  final String? patientLastName;
  final String? error;
  final BookingStep step;

  double get vatFee => (selectedDoctor?.consultationFee ?? 0) * 0.15;
  double get serviceFee => (selectedDoctor?.consultationFee ?? 0) * 0.02;
  double get totalAmount =>
      (selectedDoctor?.consultationFee ?? 0) + vatFee + serviceFee;

  BookingFlowState copyWith({
    Center? selectedCenter,
    Doctor? selectedDoctor,
    DateTime? selectedDate,
    TimeSlot? selectedSlot,
    String? reasonForVisit,
    String? symptoms,
    bool? agreedToTerms,
    bool? isProcessing,
    String? createdAppointmentId,
    String? paymentId,
    String? checkoutUrl,
    String? txRef,
    double? serverTotalAmount,
    String? patientEmail,
    String? patientPhone,
    String? patientFirstName,
    String? patientLastName,
    String? error,
    BookingStep? step,
  }) => BookingFlowState(
    selectedCenter: selectedCenter ?? this.selectedCenter,
    selectedDoctor: selectedDoctor ?? this.selectedDoctor,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedSlot: selectedSlot ?? this.selectedSlot,
    reasonForVisit: reasonForVisit ?? this.reasonForVisit,
    symptoms: symptoms ?? this.symptoms,
    agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    isProcessing: isProcessing ?? this.isProcessing,
    createdAppointmentId: createdAppointmentId ?? this.createdAppointmentId,
    paymentId: paymentId ?? this.paymentId,
    checkoutUrl: checkoutUrl ?? this.checkoutUrl,
    txRef: txRef ?? this.txRef,
    serverTotalAmount: serverTotalAmount ?? this.serverTotalAmount,
    patientEmail: patientEmail ?? this.patientEmail,
    patientPhone: patientPhone ?? this.patientPhone,
    patientFirstName: patientFirstName ?? this.patientFirstName,
    patientLastName: patientLastName ?? this.patientLastName,
    error: error,
    step: step ?? this.step,
  );

  @override
  List<Object?> get props => [
    selectedCenter,
    selectedDoctor,
    selectedDate,
    selectedSlot,
    reasonForVisit,
    symptoms,
    agreedToTerms,
    isProcessing,
    createdAppointmentId,
    paymentId,
    checkoutUrl,
    txRef,
    serverTotalAmount,
    patientEmail,
    patientPhone,
    patientFirstName,
    patientLastName,
    error,
    step,
  ];
}
