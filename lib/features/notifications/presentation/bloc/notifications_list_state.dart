import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_item.dart';

class NotificationsListState extends Equatable {
  const NotificationsListState({
    this.notifications = const [],
    this.preferences,
    this.isLoading = false,
    this.isSavingPrefs = false,
    this.errorMessage,
  });

  final List<NotificationItem> notifications;
  final NotificationPreferences? preferences;
  final bool isLoading;
  final bool isSavingPrefs;
  final String? errorMessage;

  NotificationsListState copyWith({
    List<NotificationItem>? notifications,
    NotificationPreferences? preferences,
    bool? isLoading,
    bool? isSavingPrefs,
    String? errorMessage,
  }) =>
      NotificationsListState(
        notifications: notifications ?? this.notifications,
        preferences: preferences ?? this.preferences,
        isLoading: isLoading ?? this.isLoading,
        isSavingPrefs: isSavingPrefs ?? this.isSavingPrefs,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [notifications, preferences, isLoading, isSavingPrefs, errorMessage];
}
