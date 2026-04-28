import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  const TimeSlot({
    required this.id,
    required this.dateTime,
    required this.isBooked,
  });

  final String id;
  final DateTime dateTime;
  final bool isBooked;

  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isAvailable => !isBooked && !isPast;

  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  @override
  List<Object?> get props => [id, dateTime, isBooked];
}
