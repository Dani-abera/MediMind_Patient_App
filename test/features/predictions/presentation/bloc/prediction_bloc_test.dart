import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/health_records/domain/usecases/get_record_count_usecase.dart';
import 'package:medimind/features/health_records/domain/entities/record_count.dart';
import 'package:medimind/features/predictions/domain/entities/prediction.dart';
import 'package:medimind/features/predictions/domain/usecases/get_latest_prediction_usecase.dart';
import 'package:medimind/features/predictions/domain/usecases/get_prediction_by_id_usecase.dart';
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

class MockGetRecordCountUsecase extends Mock implements GetRecordCountUsecase {}

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

void main() {
  late MockRequestPredictionUsecase mockRequest;
  late MockGetPredictionsUsecase mockGetAll;
  late MockGetLatestPredictionUsecase mockLatest;
  late MockGetPredictionByIdUsecase mockById;
  late MockGetRecordCountUsecase mockCount;

  setUp(() {
    mockRequest = MockRequestPredictionUsecase();
    mockGetAll = MockGetPredictionsUsecase();
    mockLatest = MockGetLatestPredictionUsecase();
    mockById = MockGetPredictionByIdUsecase();
    mockCount = MockGetRecordCountUsecase();
  });

  PredictionBloc build() => PredictionBloc(
        requestPrediction: mockRequest,
        getPredictions: mockGetAll,
        getLatestPrediction: mockLatest,
        getPredictionById: mockById,
        getRecordCount: mockCount,
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
        const PredictionFailure('Failed'),
      ],
    );
  });

  group('PredictionRequested — confidence thresholds', () {
    blocTest<PredictionBloc, PredictionState>(
      'emits InsufficientData when 0 records',
      build: build,
      setUp: () {
        when(() => mockCount()).thenAnswer((_) async => const Right(RecordCount(count: 0, canRequestPrediction: false)));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionInsufficientData(dataPointsUsed: 0, canRequestPrediction: false),
      ],
      verify: (_) => verifyNever(() => mockRequest()),
    );

    blocTest<PredictionBloc, PredictionState>(
      'runs prediction when 1–6 records (low confidence)',
      build: build,
      setUp: () {
        when(() => mockCount()).thenAnswer((_) async => const Right(RecordCount(count: 3, canRequestPrediction: true)));
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
      'runs prediction when 7–29 records (medium confidence)',
      build: build,
      setUp: () {
        when(() => mockCount()).thenAnswer((_) async => const Right(RecordCount(count: 15, canRequestPrediction: true)));
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
      'runs prediction when 30+ records (high confidence)',
      build: build,
      setUp: () {
        when(() => mockCount()).thenAnswer((_) async => const Right(RecordCount(count: 45, canRequestPrediction: true)));
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
      'emits failure on request error',
      build: build,
      setUp: () {
        when(() => mockCount()).thenAnswer((_) async => const Right(RecordCount(count: 10, canRequestPrediction: true)));
        when(() => mockRequest()).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Model unavailable')));
      },
      act: (bloc) => bloc.add(const PredictionRequested()),
      expect: () => [
        const PredictionProcessing(),
        const PredictionFailure('Model unavailable'),
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
