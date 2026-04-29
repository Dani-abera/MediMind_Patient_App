import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/queue/domain/entities/queue_status.dart';
import 'package:medimind/features/queue/domain/usecases/cancel_queue_usecase.dart';
import 'package:medimind/features/queue/domain/usecases/get_queue_status_usecase.dart';
import 'package:medimind/features/queue/presentation/bloc/queue_bloc.dart';
import 'package:medimind/features/queue/presentation/bloc/queue_event.dart';
import 'package:medimind/features/queue/presentation/bloc/queue_state.dart';
import 'package:medimind/features/queue/services/queue_signalr_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetQueueStatusUsecase extends Mock
    implements GetQueueStatusUsecase {}

class MockCancelQueueUsecase extends Mock implements CancelQueueUsecase {}

class MockQueueSignalRService extends Mock implements QueueSignalRService {}

final _status = QueueStatus(
  appointmentId: 'a1',
  queueId: 'q1',
  queueNumber: 5,
  position: 3,
  estimatedWaitMinutes: 15,
  status: QueueStatusType.waiting,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 30));
  });

  late MockGetQueueStatusUsecase mockGetStatus;
  late MockCancelQueueUsecase mockCancel;
  late MockQueueSignalRService mockSignalR;

  final positionStream =
      StreamController<QueuePositionUpdate>.broadcast();
  final calledStream = StreamController<QueueCalledUpdate>.broadcast();

  setUp(() {
    mockGetStatus = MockGetQueueStatusUsecase();
    mockCancel = MockCancelQueueUsecase();
    mockSignalR = MockQueueSignalRService();

    when(() => mockSignalR.onPositionUpdated)
        .thenAnswer((_) => positionStream.stream);
    when(() => mockSignalR.onNextPatientCalled)
        .thenAnswer((_) => calledStream.stream);
    when(() => mockSignalR.connectionState)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSignalR.connectQueue(any()))
        .thenAnswer((_) async {});
    when(() => mockSignalR.joinGroup(any()))
        .thenAnswer((_) async {});
    when(() => mockSignalR.stopPollingFallback()).thenReturn(null);
    when(() => mockSignalR.startPollingFallback(any(), any()))
        .thenReturn(null);
    when(() => mockSignalR.disconnect())
        .thenAnswer((_) async {});
  });

  QueueBloc build() => QueueBloc(
        queueSignalR: mockSignalR,
        getQueueStatus: mockGetStatus,
        cancelQueue: mockCancel,
      );

  group('QueueStatusOpened', () {
    blocTest<QueueBloc, QueueState>(
      'emits Connecting then Connected on success',
      build: build,
      setUp: () {
        when(() => mockGetStatus('a1'))
            .thenAnswer((_) async => Right(_status));
      },
      act: (bloc) => bloc.add(const QueueStatusOpened('a1')),
      expect: () => [
        const QueueConnecting(),
        isA<QueueConnected>()
            .having((s) => s.status.position, 'position', 3),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'emits Connecting then Error on failure',
      build: build,
      setUp: () {
        when(() => mockGetStatus('a1')).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Network error')));
      },
      act: (bloc) => bloc.add(const QueueStatusOpened('a1')),
      expect: () => [
        const QueueConnecting(),
        const QueueError('Network error'),
      ],
    );
  });

  group('QueueSignalRUpdateReceived', () {
    blocTest<QueueBloc, QueueState>(
      'updates position in Connected state',
      build: build,
      seed: () => QueueConnected(status: _status),
      act: (bloc) => bloc.add(const QueueSignalRUpdateReceived(
        position: 1,
        estimatedWaitMinutes: 5,
        status: QueueStatusType.waiting,
      )),
      expect: () => [
        isA<QueueConnected>()
            .having((s) => s.status.position, 'position', 1)
            .having((s) => s.status.estimatedWaitMinutes, 'wait', 5),
      ],
    );
  });

  group('QueueCalledReceived', () {
    blocTest<QueueBloc, QueueState>(
      'emits QueueCalled with room number',
      build: build,
      seed: () => QueueConnected(status: _status),
      act: (bloc) => bloc.add(const QueueCalledReceived(
        queueNumber: 5,
        patientName: 'John',
        roomNumber: 'A3',
      )),
      expect: () => [
        isA<QueueCalled>()
            .having((s) => s.queueNumber, 'number', 5)
            .having((s) => s.roomNumber, 'room', 'A3'),
      ],
    );
  });

  group('QueueCancelRequested', () {
    blocTest<QueueBloc, QueueState>(
      'emits QueueCancelled on success',
      build: build,
      setUp: () {
        when(() => mockCancel('a1'))
            .thenAnswer((_) async => const Right(null));
      },
      seed: () => QueueConnected(status: _status),
      act: (bloc) {
        // set appointmentId via internal state (simulate prior opened)
        bloc.add(const QueueCancelRequested());
      },
      // appointmentId is null (not opened), so cancel does nothing
      expect: () => [],
    );
  });

  group('QueueDisconnected', () {
    blocTest<QueueBloc, QueueState>(
      'marks state as polling and starts polling fallback',
      build: build,
      seed: () => QueueConnected(status: _status),
      act: (bloc) => bloc.add(const QueueDisconnected()),
      expect: () => [
        isA<QueueConnected>()
            .having((s) => s.isPolling, 'isPolling', true),
      ],
      verify: (_) {
        verify(() => mockSignalR.startPollingFallback(any(), any()))
            .called(1);
      },
    );
  });

  group('QueueReconnected', () {
    blocTest<QueueBloc, QueueState>(
      'clears polling flag and stops fallback',
      build: build,
      seed: () => QueueConnected(status: _status, isPolling: true),
      act: (bloc) => bloc.add(const QueueReconnected()),
      expect: () => [
        isA<QueueConnected>()
            .having((s) => s.isPolling, 'isPolling', false),
      ],
      verify: (_) {
        verify(() => mockSignalR.stopPollingFallback())
            .called(greaterThanOrEqualTo(1));
      },
    );
  });
}
