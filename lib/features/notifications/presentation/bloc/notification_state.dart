import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  const NotificationState({this.unreadCount = 0});
  final int unreadCount;

  NotificationState copyWith({int? unreadCount}) =>
      NotificationState(unreadCount: unreadCount ?? this.unreadCount);

  @override
  List<Object?> get props => [unreadCount];
}
