import 'package:equatable/equatable.dart';

abstract class NotificationsListEvent extends Equatable {
  const NotificationsListEvent();
  @override List<Object?> get props => [];
}

class NotificationsListRequested extends NotificationsListEvent {
  const NotificationsListRequested();
}

class NotificationsListRefreshed extends NotificationsListEvent {
  const NotificationsListRefreshed();
}

class NotificationMarkedRead extends NotificationsListEvent {
  const NotificationMarkedRead(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

class NotificationsAllMarkedRead extends NotificationsListEvent {
  const NotificationsAllMarkedRead();
}

class NotificationPreferencesRequested extends NotificationsListEvent {
  const NotificationPreferencesRequested();
}

class NotificationPreferenceUpdated extends NotificationsListEvent {
  const NotificationPreferenceUpdated({
    required this.key,
    required this.value,
  });
  final String key;
  final bool value;
  @override List<Object?> get props => [key, value];
}
