import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationPollingStarted extends NotificationEvent {
  const NotificationPollingStarted();
}

class NotificationPollingTicked extends NotificationEvent {
  const NotificationPollingTicked();
}

class NotificationFcmReceived extends NotificationEvent {
  const NotificationFcmReceived();
}

class NotificationPollingPaused extends NotificationEvent {
  const NotificationPollingPaused();
}
