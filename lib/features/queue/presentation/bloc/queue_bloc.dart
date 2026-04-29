import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/usecases/cancel_queue_usecase.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';
import '../../services/queue_signalr_service.dart';
import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc({
    required this.queueSignalR,
    required this.getQueueStatus,
    required this.cancelQueue,
  }) : super(const QueueConnecting()) {
    on<QueueStatusOpened>(_onOpened);
    on<QueueSignalRUpdateReceived>(_onSignalRUpdate);
    on<QueueCalledReceived>(_onCalled);
    on<QueuePollingTick>(_onPollingTick);
    on<QueueDisconnected>(_onDisconnected);
    on<QueueReconnected>(_onReconnected);
    on<QueueCancelRequested>(_onCancel);
    on<QueueClosed>(_onClosed);
  }

  final QueueSignalRService queueSignalR;
  final GetQueueStatusUsecase getQueueStatus;
  final CancelQueueUsecase cancelQueue;

  String? _appointmentId;
  StreamSubscription<dynamic>? _positionSub;
  StreamSubscription<dynamic>? _calledSub;
  StreamSubscription<dynamic>? _connStateSub;

  Future<void> _onOpened(
      QueueStatusOpened event, Emitter<QueueState> emit) async {
    _appointmentId = event.appointmentId;
    emit(const QueueConnecting());

    // Fetch initial status from REST
    final result = await getQueueStatus(event.appointmentId);
    result.fold(
      (f) => emit(QueueError(f.message)),
      (status) => emit(QueueConnected(status: status)),
    );

    // Connect SignalR
    _positionSub = queueSignalR.onPositionUpdated.listen((update) {
      if (update.position == -2) {
        // Signal to start polling fallback (FR-015)
        add(const QueueDisconnected());
      } else if (update.position == -1) {
        // QueueRefreshed — re-fetch from API
        add(const QueuePollingTick());
      } else {
        add(QueueSignalRUpdateReceived(
          position: update.position,
          estimatedWaitMinutes: update.estimatedWaitMinutes,
          status: update.status,
        ));
      }
    });

    _calledSub = queueSignalR.onNextPatientCalled.listen((update) {
      add(QueueCalledReceived(
        queueNumber: update.queueNumber,
        patientName: update.patientName,
        roomNumber: update.roomNumber,
      ));
    });

    _connStateSub = queueSignalR.connectionState.listen((state) {
      // handled by onReconnected/onDisconnected hooks in service
    });

    await queueSignalR.connectQueue(event.appointmentId);
    await queueSignalR.joinGroup(event.appointmentId);
  }

  void _onSignalRUpdate(
      QueueSignalRUpdateReceived event, Emitter<QueueState> emit) {
    final current = state;
    if (current is QueueConnected) {
      final updated = current.status;
      emit(QueueConnected(
        status: QueueStatus(
          appointmentId: updated.appointmentId,
          queueId: updated.queueId,
          queueNumber: updated.queueNumber,
          position: event.position,
          estimatedWaitMinutes: event.estimatedWaitMinutes,
          status: event.status,
          roomNumber: updated.roomNumber,
        ),
        isPolling: current.isPolling,
      ));
    }
  }

  void _onCalled(QueueCalledReceived event, Emitter<QueueState> emit) {
    emit(QueueCalled(
      queueNumber: event.queueNumber,
      patientName: event.patientName,
      roomNumber: event.roomNumber,
    ));
  }

  Future<void> _onPollingTick(
      QueuePollingTick event, Emitter<QueueState> emit) async {
    if (_appointmentId == null) return;
    final result = await getQueueStatus(_appointmentId!);
    result.fold(
      (f) => null, // silently ignore poll errors
      (status) {
        if (state is QueueConnected) {
          emit(QueueConnected(
              status: status, isPolling: (state as QueueConnected).isPolling));
        }
      },
    );
  }

  void _onDisconnected(QueueDisconnected event, Emitter<QueueState> emit) {
    // FR-015: start 30s polling fallback after 3 SignalR failures
    emit(state is QueueConnected
        ? (state as QueueConnected).copyWith(isPolling: true)
        : const QueueDisconnectedState());

    queueSignalR.startPollingFallback(
      const Duration(seconds: 30),
      () => add(const QueuePollingTick()),
    );
  }

  void _onReconnected(QueueReconnected event, Emitter<QueueState> emit) {
    queueSignalR.stopPollingFallback();
    if (state is QueueConnected) {
      emit((state as QueueConnected).copyWith(isPolling: false));
    }
  }

  Future<void> _onCancel(
      QueueCancelRequested event, Emitter<QueueState> emit) async {
    if (_appointmentId == null) return;
    final result = await cancelQueue(_appointmentId!);
    result.fold(
      (f) => emit(QueueError(f.message)),
      (_) => emit(const QueueCancelled()),
    );
  }

  void _onClosed(QueueClosed event, Emitter<QueueState> emit) {
    _cleanup();
  }

  void _cleanup() {
    _positionSub?.cancel();
    _calledSub?.cancel();
    _connStateSub?.cancel();
    queueSignalR.stopPollingFallback();
    queueSignalR.disconnect();
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}
