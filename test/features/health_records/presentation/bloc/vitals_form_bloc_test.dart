import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/health_records/domain/entities/health_record.dart';
import 'package:medimind/features/health_records/domain/usecases/log_vitals_usecase.dart';
import 'package:medimind/features/health_records/presentation/bloc/vitals_form/vitals_form_bloc.dart';
import 'package:medimind/features/health_records/presentation/bloc/vitals_form/vitals_form_event.dart';
import 'package:medimind/features/health_records/presentation/bloc/vitals_form/vitals_form_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLogVitalsUsecase extends Mock implements LogVitalsUsecase {}

final _record = HealthRecord(
  id: 'r1',
  recordedAt: DateTime(2025, 1, 1),
  bloodPressureSystolic: 120,
  bloodPressureDiastolic: 80,
);

void main() {
  late MockLogVitalsUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockLogVitalsUsecase();
    registerFallbackValue(const LogVitalsParams());
  });

  VitalsFormBloc build() =>
      VitalsFormBloc(logVitals: mockUsecase);

  group('VitalsFormFieldChanged', () {
    blocTest<VitalsFormBloc, VitalsFormState>(
      'updates systolic field',
      build: build,
      act: (bloc) =>
          bloc.add(const VitalsFormFieldChanged(field: 'systolic', value: '120')),
      expect: () => [
        isA<VitalsFormState>()
            .having((s) => s.systolic, 'systolic', '120')
            .having((s) => s.errors, 'errors', isEmpty),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'FR-005: error when systolic ≤ diastolic',
      build: build,
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '120'));
        bloc.add(const VitalsFormFieldChanged(
            field: 'diastolic', value: '120'));
      },
      skip: 1,
      expect: () => [
        isA<VitalsFormState>().having(
          (s) => s.errors['systolic'],
          'systolic error',
          'Systolic must be higher than diastolic BP',
        ),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'FR-005: error when systolic < diastolic',
      build: build,
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '75'));
        bloc.add(const VitalsFormFieldChanged(
            field: 'diastolic', value: '90'));
      },
      skip: 1,
      expect: () => [
        isA<VitalsFormState>().having(
          (s) => s.errors['systolic'],
          'systolic error',
          'Systolic must be higher than diastolic BP',
        ),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'no error when systolic > diastolic',
      build: build,
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '120'));
        bloc.add(const VitalsFormFieldChanged(
            field: 'diastolic', value: '80'));
      },
      skip: 1,
      expect: () => [
        isA<VitalsFormState>()
            .having((s) => s.errors, 'errors', isEmpty),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'error for non-numeric systolic',
      build: build,
      act: (bloc) => bloc.add(
          const VitalsFormFieldChanged(field: 'systolic', value: 'abc')),
      expect: () => [
        isA<VitalsFormState>().having(
          (s) => s.errors['systolic'],
          'systolic error',
          'Enter a valid number',
        ),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'SpO2 out of range error',
      build: build,
      act: (bloc) => bloc.add(const VitalsFormFieldChanged(
          field: 'oxygenSaturation', value: '110')),
      expect: () => [
        isA<VitalsFormState>().having(
          (s) => s.errors['oxygenSaturation'],
          'o2 error',
          'Must be between 0 and 100',
        ),
      ],
    );
  });

  group('VitalsFormSubmitted', () {
    blocTest<VitalsFormBloc, VitalsFormState>(
      'emits success on valid submission',
      build: build,
      setUp: () {
        when(() => mockUsecase(any()))
            .thenAnswer((_) async => Right(_record));
      },
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '120'));
        bloc.add(const VitalsFormFieldChanged(
            field: 'diastolic', value: '80'));
        bloc.add(const VitalsFormSubmitted());
      },
      expect: () => [
        isA<VitalsFormState>()
            .having((s) => s.systolic, 'sys', '120'),
        isA<VitalsFormState>()
            .having((s) => s.diastolic, 'dia', '80'),
        isA<VitalsFormState>()
            .having((s) => s.status, 'status', VitalsFormStatus.loading),
        isA<VitalsFormState>()
            .having((s) => s.status, 'status', VitalsFormStatus.success)
            .having((s) => s.savedRecord, 'record', _record),
      ],
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'does not submit when FR-005 violation present',
      build: build,
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '80'));
        bloc.add(const VitalsFormFieldChanged(
            field: 'diastolic', value: '120'));
        bloc.add(const VitalsFormSubmitted());
      },
      // Submit re-emits the same error state as the field change,
      // which BLoC deduplicates — so only 2 states are emitted.
      expect: () => [
        isA<VitalsFormState>()
            .having((s) => s.systolic, 'sys', '80'),
        isA<VitalsFormState>().having(
          (s) => s.errors['systolic'],
          'bp error',
          'Systolic must be higher than diastolic BP',
        ),
      ],
      verify: (_) => verifyNever(() => mockUsecase(any())),
    );

    blocTest<VitalsFormBloc, VitalsFormState>(
      'emits failure on server error',
      build: build,
      setUp: () {
        when(() => mockUsecase(any())).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Network error')));
      },
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'glucose', value: '100'));
        bloc.add(const VitalsFormSubmitted());
      },
      skip: 1,
      expect: () => [
        isA<VitalsFormState>()
            .having((s) => s.status, 'status', VitalsFormStatus.loading),
        isA<VitalsFormState>()
            .having((s) => s.status, 'status', VitalsFormStatus.failure)
            .having((s) => s.errorMessage, 'error', 'Network error'),
      ],
    );
  });

  group('VitalsFormReset', () {
    blocTest<VitalsFormBloc, VitalsFormState>(
      'resets state to initial',
      build: build,
      act: (bloc) {
        bloc.add(const VitalsFormFieldChanged(
            field: 'systolic', value: '130'));
        bloc.add(const VitalsFormReset());
      },
      skip: 1,
      expect: () => [const VitalsFormState()],
    );
  });
}
