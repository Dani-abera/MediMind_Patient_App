import 'package:equatable/equatable.dart';

enum ConsultationStatus { scheduled, active, ended, cancelled }

class VideoConsultation extends Equatable {
  const VideoConsultation({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorAvatarUrl,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.notes,
  });

  final String id;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatarUrl;
  final ConsultationStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? notes;

  @override
  List<Object?> get props => [
        id, doctorName, doctorSpecialty, doctorAvatarUrl,
        status, scheduledAt, startedAt, endedAt, notes,
      ];
}
