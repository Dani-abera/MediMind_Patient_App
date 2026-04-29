import 'package:equatable/equatable.dart';
import '../../domain/entities/queue_status.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();
  @override
  List<Object?> get props => [];
}

class QueueStatusOpened extends QueueEvent {
  const QueueStatusOpened(this.appointmentId);
  final String appointmentId;
  @override
  List<Object?> get props => [appointmentId];
}

class QueueSignalRUpdateReceived extends QueueEvent {
  const QueueSignalRUpdateReceived({
    required this.position,
    required this.estimatedWaitMinutes,
    required this.status,
  });
  final int position;
  final int estimatedWaitMinutes;
  final QueueStatusType status;
  @override
  List<Object?> get props => [position, estimatedWaitMinutes, status];
}

class QueueCalledReceived extends QueueEvent {
  const QueueCalledReceived({
    required this.queueNumber,
    required this.patientName,
    this.roomNumber,
  });
  final int queueNumber;
  final String patientName;
  final String? roomNumber;
  @override
  List<Object?> get props => [queueNumber, patientName, roomNumber];
}

class QueuePollingTick extends QueueEvent {
  const QueuePollingTick();
}

class QueueDisconnected extends QueueEvent {
  const QueueDisconnected();
}

class QueueReconnected extends QueueEvent {
  const QueueReconnected();
}

class QueueCancelRequested extends QueueEvent {
  const QueueCancelRequested();
}

class QueueClosed extends QueueEvent {
  const QueueClosed();
}
