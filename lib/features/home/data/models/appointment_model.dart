import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.doctorName,
    required super.doctorSpecialization,
    required super.centerName,
    required super.appointmentTime,
    required super.status,
    super.doctorAvatarUrl,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>? ?? {};
    final center = json['center'] as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      doctorName: doctor['fullName'] as String? ?? 'Unknown Doctor',
      doctorSpecialization:
          doctor['specialization'] as String? ?? '',
      doctorAvatarUrl: doctor['profileImageUrl'] as String?,
      centerName: center['name'] as String? ?? 'Unknown Center',
      appointmentTime: DateTime.parse(json['appointmentTime'] as String),
      status: json['status'] as String? ?? 'confirmed',
    );
  }
}
