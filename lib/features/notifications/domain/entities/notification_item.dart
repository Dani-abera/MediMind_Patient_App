import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.deepLinkData,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? deepLinkData;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        deepLinkData: deepLinkData,
      );

  @override
  List<Object?> get props =>
      [id, title, body, type, createdAt, isRead, deepLinkData];
}

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.appointmentReminders = true,
    this.appointmentSms = true,
    this.queueUpdates = true,
    this.predictionReady = true,
    this.medicationReminders = true,
    this.promotional = false,
  });

  final bool appointmentReminders;
  final bool appointmentSms;
  final bool queueUpdates;
  final bool predictionReady;
  final bool medicationReminders;
  final bool promotional;

  NotificationPreferences copyWith({
    bool? appointmentReminders,
    bool? appointmentSms,
    bool? queueUpdates,
    bool? predictionReady,
    bool? medicationReminders,
    bool? promotional,
  }) =>
      NotificationPreferences(
        appointmentReminders:
            appointmentReminders ?? this.appointmentReminders,
        appointmentSms: appointmentSms ?? this.appointmentSms,
        queueUpdates: queueUpdates ?? this.queueUpdates,
        predictionReady: predictionReady ?? this.predictionReady,
        medicationReminders: medicationReminders ?? this.medicationReminders,
        promotional: promotional ?? this.promotional,
      );

  Map<String, dynamic> toJson() => {
        'appointmentReminders': appointmentReminders,
        'appointmentSms': appointmentSms,
        'queueUpdates': queueUpdates,
        'predictionReady': predictionReady,
        'medicationReminders': medicationReminders,
        'promotional': promotional,
      };

  @override
  List<Object?> get props => [
        appointmentReminders, appointmentSms, queueUpdates,
        predictionReady, medicationReminders, promotional,
      ];
}
