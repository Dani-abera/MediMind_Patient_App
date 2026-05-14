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
    final rawQn = json['queueNumber']?.toString() ?? '';
    final queueNumber =
        int.tryParse(rawQn.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return QueueStatusModel(
      appointmentId: json['appointmentId'] as String? ?? '',
      queueId: json['queueId'] as String? ?? '',
      queueNumber: queueNumber,
      position: json['currentPosition'] as int? ?? 0,
      estimatedWaitMinutes: json['estimatedWaitTimeMinutes'] as int? ?? 0,
      status: _parseStatus(json['status'] as String? ?? ''),
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
