import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/appointments/domain/entities/appointment_detail.dart';
import 'package:medimind/features/appointments/domain/entities/time_slot.dart';
import 'package:medimind/features/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:medimind/features/appointments/presentation/bloc/booking_flow/booking_flow_bloc.dart';
import 'package:medimind/features/appointments/presentation/bloc/booking_flow/booking_flow_event.dart';
import 'package:medimind/features/appointments/presentation/bloc/booking_flow/booking_flow_state.dart';
import 'package:medimind/features/centers/domain/entities/center.dart';
import 'package:medimind/features/doctors/domain/entities/doctor.dart';
import 'package:medimind/features/payments/domain/entities/payment.dart'
    as pay;
import 'package:medimind/features/payments/domain/usecases/initiate_payment_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateAppointmentUsecase extends Mock
    implements CreateAppointmentUsecase {}

class MockInitiatePaymentUsecase extends Mock
    implements InitiatePaymentUsecase {}

class FakeCreateAppointmentParams extends Fake
    implements CreateAppointmentParams {}

const _center = Center(
  id: 'c1',
  name: 'Test Center',
  type: CenterType.clinic,
  address: '123 Street',
  city: 'Addis Ababa',
  phone: '+251911000000',
  rating: 4.5,
  reviewCount: 10,
  distanceKm: 1.2,
  specializations: ['General'],
  isOpenNow: true,
  isFavorite: false,
);

const _doctor = Doctor(
  id: 'd1',
  fullName: 'John Doe',
  specialization: 'General',
  yearsExperience: 5,
  rating: 4.8,
  reviewCount: 20,
  patientsSeen: 200,
  consultationFee: 500,
  languages: ['English'],
  qualifications: ['MBBS'],
  centerIds: ['c1'],
);

final _slot = TimeSlot(
  id: 's1',
  dateTime: DateTime.now().add(const Duration(hours: 2)),
  isBooked: false,
);

final _appointment = AppointmentDetail(
  id: 'apt1',
  doctorId: 'd1',
  doctorName: 'John Doe',
  doctorSpecialization: 'General',
  centerId: 'c1',
  centerName: 'Test Center',
  centerAddress: '123 Street',
  centerPhone: '+251911000000',
  appointmentTime: DateTime(2025, 6, 1, 9, 0),
  status: AppointmentStatus.pending,
  type: AppointmentType.inPerson,
  consultationFee: 500,
  serviceFee: 10,
  totalAmount: 510,
  canCancel: true,
  canReschedule: false,
);

final _payment = pay.Payment(
  id: 'pay1',
  appointmentId: 'apt1',
  amount: 510,
  status: pay.PaymentStatus.pending,
  currency: 'ETB',
  checkoutUrl: 'https://checkout.chapa.co/pay',
);

void main() {
  late MockCreateAppointmentUsecase mockCreate;
  late MockInitiatePaymentUsecase mockInitiate;

  setUpAll(() {
    registerFallbackValue(FakeCreateAppointmentParams());
  });

  setUp(() {
    mockCreate = MockCreateAppointmentUsecase();
    mockInitiate = MockInitiatePaymentUsecase();
  });

  BookingFlowBloc buildBloc() => BookingFlowBloc(
        createAppointment: mockCreate,
        initiatePayment: mockInitiate,
      );

  group('CenterSelected', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'sets center and advances step to selectDoctor',
      build: buildBloc,
      act: (b) => b.add(const CenterSelected(_center)),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.selectedCenter, 'center', _center)
            .having((s) => s.step, 'step', BookingStep.selectDoctor),
      ],
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'clears doctor/slot when center changes',
      build: buildBloc,
      seed: () => BookingFlowState(
        selectedCenter: _center,
        selectedDoctor: _doctor,
        selectedSlot: _slot,
        step: BookingStep.selectSlot,
      ),
      act: (b) => b.add(const CenterSelected(_center)),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.selectedDoctor, 'doctor', null)
            .having((s) => s.selectedSlot, 'slot', null),
      ],
    );
  });

  group('DoctorSelected', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'sets doctor and advances step to selectSlot',
      build: buildBloc,
      seed: () => const BookingFlowState(selectedCenter: _center),
      act: (b) => b.add(const DoctorSelected(_doctor)),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.selectedDoctor, 'doctor', _doctor)
            .having((s) => s.step, 'step', BookingStep.selectSlot),
      ],
    );
  });

  group('TermsToggled', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'toggles agreedToTerms from false to true',
      build: buildBloc,
      act: (b) => b.add(const TermsToggled()),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.agreedToTerms, 'agreed', true),
      ],
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'toggles agreedToTerms back to false',
      build: buildBloc,
      seed: () => const BookingFlowState(agreedToTerms: true),
      act: (b) => b.add(const TermsToggled()),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.agreedToTerms, 'agreed', false),
      ],
    );
  });

  group('BookingConfirmed', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'emits processing then payment state on success',
      build: () {
        when(() => mockCreate(any()))
            .thenAnswer((_) async => Right(_appointment));
        when(() => mockInitiate(_appointment.id))
            .thenAnswer((_) async => Right(_payment));
        return buildBloc();
      },
      seed: () => BookingFlowState(
        selectedCenter: _center,
        selectedDoctor: _doctor,
        selectedDate: DateTime.now(),
        selectedSlot: _slot,
        reasonForVisit: 'Checkup',
        agreedToTerms: true,
        step: BookingStep.fillSummary,
      ),
      act: (b) => b.add(const BookingConfirmed()),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.isProcessing, 'isProcessing', true)
            .having((s) => s.step, 'step', BookingStep.processing),
        isA<BookingFlowState>()
            .having((s) => s.step, 'step', BookingStep.payment)
            .having((s) => s.checkoutUrl, 'checkoutUrl',
                'https://checkout.chapa.co/pay')
            .having((s) => s.isProcessing, 'isProcessing', false),
      ],
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'returns to fillSummary with error when appointment creation fails',
      build: () {
        when(() => mockCreate(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );
        return buildBloc();
      },
      seed: () => BookingFlowState(
        selectedCenter: _center,
        selectedDoctor: _doctor,
        selectedDate: DateTime.now(),
        selectedSlot: _slot,
        reasonForVisit: 'Checkup',
        step: BookingStep.fillSummary,
      ),
      act: (b) => b.add(const BookingConfirmed()),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.step, 'step', BookingStep.processing),
        isA<BookingFlowState>()
            .having((s) => s.step, 'step', BookingStep.fillSummary)
            .having((s) => s.error, 'error', 'Network error'),
      ],
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'does nothing when required fields are missing',
      build: buildBloc,
      act: (b) => b.add(const BookingConfirmed()),
      expect: () => [],
    );
  });

  group('PaymentCompleted', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'advances step to confirmed',
      build: buildBloc,
      seed: () => const BookingFlowState(step: BookingStep.payment),
      act: (b) => b.add(const PaymentCompleted()),
      expect: () => [
        isA<BookingFlowState>()
            .having((s) => s.step, 'step', BookingStep.confirmed),
      ],
    );
  });

  group('BookingReset', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => BookingFlowState(
        selectedCenter: _center,
        selectedDoctor: _doctor,
        step: BookingStep.confirmed,
      ),
      act: (b) => b.add(const BookingReset()),
      expect: () => [const BookingFlowState()],
    );
  });
}
