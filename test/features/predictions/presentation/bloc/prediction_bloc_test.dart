import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/predictions/domain/entities/prediction.dart';
import 'package:medimind/features/predictions/domain/entities/prediction_status.dart';
import 'package:medimind/features/predictions/domain/usecases/get_latest_prediction_usecase.dart';
import 'package:medimind/features/predictions/domain/usecases/get_prediction_by_id_usecase.dart';
import 'package:medimind/features/predictions/domain/usecases/get_prediction_status_usecase.dart';
import 'package:medimind/features/predictions/domain/usecases/get_predictions_usecase.dart';
import 'package:medimind/features/predictions/domain/usecases/request_prediction_usecase.dart';
import 'package:medimind/features/predictions/presentation/bloc/prediction/prediction_bloc.dart';
import 'package:medimind/features/predictions/presentation/bloc/prediction/prediction_event.dart';
import 'package:medimind/features/predictions/presentation/bloc/prediction/prediction_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestPredictionUsecase extends Mock
    implements RequestPredictionUsecase {}

class MockGetPredictionsUsecase extends Mock implements GetPredictionsUsecase {}

class MockGetLatestPredictionUsecase extends Mock
    implements GetLatestPredictionUsecase {}

class MockGetPredictionByIdUsecase extends Mock
    implements GetPredictionByIdUsecase {}

class MockGetPredictionStatusUsecase extends Mock
    implements GetPredictionStatusUsecase {}

final _diseaseRisk = DiseaseRisk(
  riskScore: 20,
  riskLevel: RiskLevel.low,
  contributingFactors: const [],
);

final _prediction = Prediction(
  id: 'p1',
  createdAt: DateTime(2025, 1, 1),
  dataPointsUsed: 30,
  confidenceLevel: 'high',
  diabetes: _diseaseRisk,
  hypertension: _diseaseRisk,
  cardiovascular: _diseaseRisk,
);

const _statusCanRequest = PredictionStatus(
  canRequest: true,
  healthRecordCount: 15,
  confidenceLevel: 'Medium',
  message: 'You have 15 records. Keep logging.',
);

const _statusCannotRequest = PredictionStatus(
  canRequest: false,
  healthRecordCount: 0,
  confidenceLevel: 'Low',
  message: 'Start logging your vital signs to unlock AI health predictions.',
);

void main() {
  late MockRequestPredictionUsecase mockRequest;
  late MockGetPredictionsUsecase mockGetAll;
  late MockGetLatestPredictionUsecase mockLatest;
  late MockGetPredictionByIdUsecase mockById;
  late MockGetPredictionStatusUsecase mockStatus;

  setUp(() {
    mockRequest = MockRequestPredictionUsecase();
    mockGetAll = MockGetPredictionsUsecase();
    mockLatest = MockGetLatestPredictionUsecase();
    mockById = MockGetPredictionByIdUsecase();
    mockStatus = MockGetPredictionStatusUsecase();
  });

  PredictionBloc build() => PredictionBloc(
        requestPrediction: mockRequest,
        getPredictions: mockGetAll,
        getLatestPrediction: mockLatest,
        getPredictionById: mockById,
        getPredictionStatus: mockStatus,
      );

  group('PredictionsRequested', () {
    blocTest<PredictionBloc, PredictionState>(
      'emits PredictionsLoaded on success',
      build: build,
      setUp: () {
        when(() => mockGetAll()).thenAnswer(
            (_) async => Right([_prediction]));
        when(() => mockLatest())
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const PredictionsRequested()),
      expect: () => [
        const PredictionsLoading(),
        isA<PredictionsLoaded>()
            .having((s) => s.predictions.length, 'count', 1),
      ],
    );

    blocTest<PredictionBloc, PredictionState>(
      'emits PredictionFailure on error',
      build: build,
      setUp: () {
        when(() => mockGetAll()).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Failed')));
        when(() => mockLatest())
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const PredictionsRequested()),
      expect: () => [
        const PredictionsLoading(),
        const PredictionFailure('Something went wrong. Please try again.'),
      ],
    );
  });

  group('PredictionRequested — status gating', () {
    blocTest<PredictionBloc, PredictionState>(
      'emits InsufficientData when status.canRequest is false',
      build: build,
      setUp: () {
        when(() => mockStatus())
            .thenAnswer((_) async => const Right(_statusCannotRequest));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        PredictionInsufficientData(
          dataPointsUsed: _statusCannotRequest.healthRecordCount,
          canRequestPrediction: false,
          message: _statusCannotRequest.message,
        ),
      ],
      verify: (_) => verifyNever(() => mockRequest()),
    );

    blocTest<PredictionBloc, PredictionState>(
      'proceeds with prediction when status check fails (falls back to backend validation)',
      build: build,
      setUp: () {
        when(() => mockStatus()).thenAnswer(
            (_) async => const Left(NetworkFailure()));
        when(() => mockRequest())
            .thenAnswer((_) async => Right(_prediction));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionProcessing(),
        PredictionSuccess(_prediction),
      ],
    );

    blocTest<PredictionBloc, PredictionState>(
      'runs prediction when status.canRequest is true',
      build: build,
      setUp: () {
        when(() => mockStatus())
            .thenAnswer((_) async => const Right(_statusCanRequest));
        when(() => mockRequest())
            .thenAnswer((_) async => Right(_prediction));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionProcessing(),
        PredictionSuccess(_prediction),
      ],
    );

    blocTest<PredictionBloc, PredictionState>(
      'emits user-friendly failure on network error',
      build: build,
      setUp: () {
        when(() => mockStatus())
            .thenAnswer((_) async => const Right(_statusCanRequest));
        when(() => mockRequest()).thenAnswer((_) async =>
            const Left(NetworkFailure()));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionProcessing(),
        const PredictionFailure(
            'No internet connection. Please check your connection and try again.'),
      ],
    );

    blocTest<PredictionBloc, PredictionState>(
      'emits user-friendly failure on 503 error',
      build: build,
      setUp: () {
        when(() => mockStatus())
            .thenAnswer((_) async => const Right(_statusCanRequest));
        when(() => mockRequest()).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'unavailable', code: 503)));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionProcessing(),
        const PredictionFailure(
            'Our AI is temporarily unavailable. Please try again in a few minutes.'),
      ],
    );
  });

  group('PredictionDetailRequested', () {
    blocTest<PredictionBloc, PredictionState>(
      'emits PredictionDetailLoaded on success',
      build: build,
      setUp: () {
        when(() => mockById('p1'))
            .thenAnswer((_) async => Right(_prediction));
      },
      act: (bloc) =>
          bloc.add(const PredictionDetailRequested('p1')),
      expect: () => [
        const PredictionsLoading(),
        PredictionDetailLoaded(_prediction),
      ],
    );
  });
}
