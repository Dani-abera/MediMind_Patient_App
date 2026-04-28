import 'package:equatable/equatable.dart';

class WorkingHours extends Equatable {
  const WorkingHours({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  final String day;
  final String openTime;
  final String closeTime;
  final bool isOpen;

  String get displayHours => isOpen ? '$openTime – $closeTime' : 'Closed';

  @override
  List<Object?> get props => [day, openTime, closeTime, isOpen];
}
