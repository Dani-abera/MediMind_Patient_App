import 'dart:async';
import '../../../core/services/signalr_service.dart';
import '../domain/entities/queue_status.dart';

class QueuePositionUpdate {
  QueuePositionUpdate({
    required this.queueId,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.status,
  });
  final String queueId;
  final int position;
  final int estimatedWaitMinutes;
  final QueueStatusType status;
}

class QueueCalledUpdate {
  QueueCalledUpdate({
    required this.queueId,
    required this.queueNumber,
    required this.patientName,
    this.roomNumber,
  });
  final String queueId;
  final int queueNumber;
  final String patientName;
  final String? roomNumber;
}

class QueueSignalRService extends SignalRService {
  QueueSignalRService({required super.secureStorage})
      : super(hubPath: '/hubs/queue');

  String? _currentAppointmentId;
  int _signalRFailCount = 0;
  static const _maxSignalRFailsBeforePoll = 3;

  final _positionController =
      StreamController<QueuePositionUpdate>.broadcast();
  final _calledController =
      StreamController<QueueCalledUpdate>.broadcast();

  Stream<QueuePositionUpdate> get onPositionUpdated =>
      _positionController.stream;
  Stream<QueueCalledUpdate> get onNextPatientCalled =>
      _calledController.stream;

  Future<void> connectQueue(String appointmentId) async {
    _currentAppointmentId = appointmentId;
    _registerHandlers();
    await connect();
  }

  void _registerHandlers() {
    on('QueuePositionUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      _positionController.add(QueuePositionUpdate(
        queueId: data['queueId'] as String? ?? '',
        position: data['position'] as int? ?? 0,
        estimatedWaitMinutes: data['estimatedWaitTimeMinutes'] as int? ?? 0,
        status: _parseStatus(data['status'] as String? ?? ''),
      ));
    });

    on('NextPatientCalled', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      _calledController.add(QueueCalledUpdate(
        queueId: data['queueId'] as String? ?? '',
        queueNumber: int.tryParse(
            (data['queueNumber']?.toString() ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        patientName: data['patientName'] as String? ?? '',
        roomNumber: data['roomNumber'] as String?,
      ));
    });

    on('QueueRefreshed', (_) {
      if (_currentAppointmentId != null) {
        // position == -1 signals the BLoC to re-fetch from API
        _positionController.add(QueuePositionUpdate(
          queueId: '',
          position: -1,
          estimatedWaitMinutes: 0,
          status: QueueStatusType.waiting,
        ));
      }
    });
  }

  @override
  void onReconnected() {
    _signalRFailCount = 0;
    stopPollingFallback();
    if (_currentAppointmentId != null) {
      send('JoinPatientGroup', args: []);
    }
  }

  @override
  void onDisconnected() {
    _signalRFailCount++;
    if (_signalRFailCount >= _maxSignalRFailsBeforePoll) {
      // position == -2 signals the BLoC to switch to polling
      _positionController.add(QueuePositionUpdate(
        queueId: '',
        position: -2,
        estimatedWaitMinutes: 0,
        status: QueueStatusType.waiting,
      ));
    }
  }

  Future<void> joinGroup(String appointmentId) async {
    await send('JoinPatientGroup', args: []);
  }

  static QueueStatusType _parseStatus(String s) => switch (s.toLowerCase()) {
        'called' => QueueStatusType.called,
        'completed' => QueueStatusType.completed,
        'cancelled' => QueueStatusType.cancelled,
        _ => QueueStatusType.waiting,
      };

  @override
  void dispose() {
    _positionController.close();
    _calledController.close();
    super.dispose();
  }
}
