import 'package:equatable/equatable.dart';

enum QueueStatusType { waiting, called, completed, cancelled }

class QueueStatus extends Equatable {
  const QueueStatus({
    required this.appointmentId,
    required this.queueId,
    required this.queueNumber,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.status,
    this.roomNumber,
  });

  final String appointmentId;
  final String queueId;
  final int queueNumber;
  final int position;
  final int estimatedWaitMinutes;
  final QueueStatusType status;
  final String? roomNumber;

  @override
  List<Object?> get props => [
        appointmentId,
        queueId,
        queueNumber,
        position,
        estimatedWaitMinutes,
        status,
        roomNumber,
      ];
}
