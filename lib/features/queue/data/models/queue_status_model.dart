import '../../domain/entities/queue_status.dart';

class QueueStatusModel extends QueueStatus {
  const QueueStatusModel({
    required super.appointmentId,
    required super.queueId,
    required super.queueNumber,
    required super.position,
    required super.estimatedWaitMinutes,
    required super.status,
    super.roomNumber,
  });

  factory QueueStatusModel.fromJson(Map<String, dynamic> json) {
    return QueueStatusModel(
      appointmentId: json['appointmentId'] as String,
      queueId: json['queueId'] as String,
      queueNumber: json['queueNumber'] as int,
      position: json['position'] as int,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int,
      status: _parseStatus(json['status'] as String),
      roomNumber: json['roomNumber'] as String?,
    );
  }

  static QueueStatusType _parseStatus(String s) => switch (s.toLowerCase()) {
        'called' => QueueStatusType.called,
        'completed' => QueueStatusType.completed,
        'cancelled' => QueueStatusType.cancelled,
        _ => QueueStatusType.waiting,
      };
}
