import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/medical_history/domain/entities/medical_history.dart';
import 'package:medimind/features/medical_history/domain/usecases/get_medical_history_usecase.dart';
import 'package:medimind/features/medical_history/domain/usecases/update_medical_history_usecase.dart';
import 'package:medimind/features/medical_history/presentation/bloc/medical_history_bloc.dart';
import 'package:medimind/features/medical_history/presentation/bloc/medical_history_event.dart';
import 'package:medimind/features/medical_history/presentation/bloc/medical_history_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMedicalHistoryUsecase extends Mock
    implements GetMedicalHistoryUsecase {}

class MockUpdateMedicalHistoryUsecase extends Mock
    implements UpdateMedicalHistoryUsecase {}

const _history = MedicalHistory(
  bloodType: 'O+',
  chronicConditions: ['Hypertension'],
  isSmoker: false,
  alcoholConsumption: AlcoholConsumption.none,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_history);
  });

  late MockGetMedicalHistoryUsecase mockGet;
  late MockUpdateMedicalHistoryUsecase mockUpdate;

  setUp(() {
    mockGet = MockGetMedicalHistoryUsecase();
    mockUpdate = MockUpdateMedicalHistoryUsecase();
  });

  MedicalHistoryBloc build() => MedicalHistoryBloc(
        getMedicalHistory: mockGet,
        updateMedicalHistory: mockUpdate,
      );

  group('MedicalHistoryRequested', () {
    blocTest<MedicalHistoryBloc, MedicalHistoryState>(
      'emits [Loading, Loaded] on success',
      setUp: () => when(() => mockGet()).thenAnswer(
          (_) async => const Right(_history)),
      build: build,
      act: (b) => b.add(const MedicalHistoryRequested()),
      expect: () => [
        const MedicalHistoryLoading(),
        const MedicalHistoryLoaded(_history),
      ],
    );

    blocTest<MedicalHistoryBloc, MedicalHistoryState>(
      'emits [Loading, Failure] on error',
      setUp: () => when(() => mockGet()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'oops'))),
      build: build,
      act: (b) => b.add(const MedicalHistoryRequested()),
      expect: () => [
        const MedicalHistoryLoading(),
        const MedicalHistoryFailure('oops'),
      ],
    );
  });

  group('MedicalHistoryUpdated', () {
    blocTest<MedicalHistoryBloc, MedicalHistoryState>(
      'emits [Saving, Saved] on success',
      setUp: () => when(() => mockUpdate(any())).thenAnswer(
          (_) async => const Right(_history)),
      build: build,
      act: (b) => b.add(const MedicalHistoryUpdated(_history)),
      expect: () => [
        const MedicalHistorySaving(_history),
        const MedicalHistorySaved(_history),
      ],
    );

    blocTest<MedicalHistoryBloc, MedicalHistoryState>(
      'emits [Saving, Failure] on error',
      setUp: () => when(() => mockUpdate(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'save failed'))),
      build: build,
      act: (b) => b.add(const MedicalHistoryUpdated(_history)),
      expect: () => [
        const MedicalHistorySaving(_history),
        const MedicalHistoryFailure('save failed'),
      ],
    );
  });
}
