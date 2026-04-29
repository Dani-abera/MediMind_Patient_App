import 'package:equatable/equatable.dart';
import '../../domain/entities/queue_status.dart';

abstract class QueueState extends Equatable {
  const QueueState();
  @override
  List<Object?> get props => [];
}

class QueueConnecting extends QueueState {
  const QueueConnecting();
}

class QueueConnected extends QueueState {
  const QueueConnected({
    required this.status,
    this.isPolling = false,
  });
  final QueueStatus status;
  final bool isPolling;

  QueueConnected copyWith({QueueStatus? status, bool? isPolling}) =>
      QueueConnected(
        status: status ?? this.status,
        isPolling: isPolling ?? this.isPolling,
      );

  @override
  List<Object?> get props => [status, isPolling];
}

class QueueCalled extends QueueState {
  const QueueCalled({
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

class QueueDisconnectedState extends QueueState {
  const QueueDisconnectedState();
}

class QueueCancelled extends QueueState {
  const QueueCancelled();
}

class QueueError extends QueueState {
  const QueueError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
