import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.centerName,
    required this.appointmentTime,
    required this.status,
    this.doctorAvatarUrl,
  });

  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final String centerName;
  final DateTime appointmentTime;
  final String status;
  final String? doctorAvatarUrl;

  @override
  List<Object?> get props => [
        id,
        doctorName,
        doctorSpecialization,
        centerName,
        appointmentTime,
        status,
        doctorAvatarUrl,
      ];
}
