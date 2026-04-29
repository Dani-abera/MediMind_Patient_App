import '../../domain/entities/notification_item.dart';

class NotificationItemModel extends NotificationItem {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.deepLinkData,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      NotificationItemModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? json['message'] as String? ?? '',
        type: json['type'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
        deepLinkData: json['data'] as Map<String, dynamic>?,
      );
}

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    super.appointmentReminders,
    super.appointmentSms,
    super.queueUpdates,
    super.predictionReady,
    super.medicationReminders,
    super.promotional,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      NotificationPreferencesModel(
        appointmentReminders: json['appointmentReminders'] as bool? ?? true,
        appointmentSms: json['appointmentSms'] as bool? ?? true,
        queueUpdates: json['queueUpdates'] as bool? ?? true,
        predictionReady: json['predictionReady'] as bool? ?? true,
        medicationReminders: json['medicationReminders'] as bool? ?? true,
        promotional: json['promotional'] as bool? ?? false,
      );
}
