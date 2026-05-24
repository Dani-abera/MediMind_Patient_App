import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_appointment_usecase.dart';
import '../../../../payments/domain/usecases/initiate_payment_usecase.dart';
import 'booking_flow_event.dart';
import 'booking_flow_state.dart';

class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  BookingFlowBloc({
    required CreateAppointmentUsecase createAppointment,
    required InitiatePaymentUsecase initiatePayment,
  })  : _createAppointment = createAppointment,
        _initiatePayment = initiatePayment,
        super(const BookingFlowState()) {
    on<CenterSelected>(_onCenterSelected);
    on<DoctorSelected>(_onDoctorSelected);
    on<SlotSelected>(_onSlotSelected);
    on<ReasonEntered>(_onReasonEntered);
    on<TermsToggled>(_onTermsToggled);
    on<BookingConfirmed>(_onBookingConfirmed);
    on<PaymentCompleted>(_onPaymentCompleted);
    on<BookingReset>(_onReset);
  }

  final CreateAppointmentUsecase _createAppointment;
  final InitiatePaymentUsecase _initiatePayment;

  void _onCenterSelected(CenterSelected event, Emitter<BookingFlowState> emit) {
    emit(BookingFlowState(
      selectedCenter: event.center,
      step: BookingStep.selectDoctor,
    ));
  }

  void _onDoctorSelected(DoctorSelected event, Emitter<BookingFlowState> emit) {
    emit(BookingFlowState(
      selectedCenter: state.selectedCenter,
      selectedDoctor: event.doctor,
      step: BookingStep.selectSlot,
    ));
  }

  void _onSlotSelected(SlotSelected event, Emitter<BookingFlowState> emit) {
    emit(state.copyWith(
      selectedDate: event.date,
      selectedSlot: event.slot,
      step: BookingStep.fillSummary,
    ));
  }

  void _onReasonEntered(ReasonEntered event, Emitter<BookingFlowState> emit) {
    emit(state.copyWith(
      reasonForVisit: event.reason,
      symptoms: event.symptoms,
    ));
  }

  void _onTermsToggled(TermsToggled event, Emitter<BookingFlowState> emit) {
    emit(state.copyWith(agreedToTerms: !state.agreedToTerms));
  }

  Future<void> _onBookingConfirmed(
    BookingConfirmed event,
    Emitter<BookingFlowState> emit,
  ) async {
    final doctor = state.selectedDoctor;
    final center = state.selectedCenter;
    final slot = state.selectedSlot;
    final date = state.selectedDate;
    if (doctor == null || center == null || slot == null || date == null) return;

    emit(state.copyWith(isProcessing: true, step: BookingStep.processing));

    final appointmentResult = await _createAppointment(
      CreateAppointmentParams(
        doctorId: doctor.id,
        centerId: center.id,
        appointmentTime: slot.dateTime,
        slotId: slot.id,
        reasonForVisit: state.reasonForVisit,
        symptoms: state.symptoms,
      ),
    );

    await appointmentResult.fold(
      (failure) async {
        emit(state.copyWith(
          isProcessing: false,
          error: failure.message,
          step: BookingStep.fillSummary,
        ));
      },
      (appointment) async {
        final paymentResult =
            await _initiatePayment(appointment.id);
        paymentResult.fold(
          (failure) => emit(state.copyWith(
            isProcessing: false,
            error: failure.message,
            step: BookingStep.fillSummary,
          )),
          (payment) => emit(state.copyWith(
            isProcessing: false,
            createdAppointmentId: appointment.id,
            paymentId: payment.id,
            txRef: payment.txRef,
            serverTotalAmount: payment.amount,
            patientEmail: payment.patientEmail,
            patientPhone: payment.patientPhone,
            patientFirstName: payment.patientFirstName,
            patientLastName: payment.patientLastName,
            step: BookingStep.payment,
          )),
        );
      },
    );
  }

  void _onPaymentCompleted(
      PaymentCompleted event, Emitter<BookingFlowState> emit) {
    emit(state.copyWith(step: BookingStep.confirmed));
  }

  void _onReset(BookingReset event, Emitter<BookingFlowState> emit) {
    emit(const BookingFlowState());
  }
}
