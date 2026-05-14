import '../../domain/entities/video_consultation.dart';

class VideoConsultationModel extends VideoConsultation {
  const VideoConsultationModel({
    required super.id,
    required super.doctorName,
    required super.doctorSpecialty,
    required super.doctorAvatarUrl,
    required super.status,
    required super.scheduledAt,
    super.startedAt,
    super.endedAt,
    super.notes,
  });

  factory VideoConsultationModel.fromJson(Map<String, dynamic> json) {
    final doctorInfo = json['doctorInfo'] as Map<String, dynamic>? ?? {};
    return VideoConsultationModel(
      id: json['consultationId'] as String,
      doctorName: doctorInfo['fullName'] as String? ?? '',
      doctorSpecialty: doctorInfo['specialization'] as String? ?? '',
      doctorAvatarUrl: doctorInfo['profileImageUrl'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? ''),
      scheduledAt: _parseScheduledAt(
        json['appointmentDate'] as String?,
        json['appointmentTime'] as String?,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  static ConsultationStatus _parseStatus(String s) =>
      switch (s.toLowerCase()) {
        'inprogress' || 'in_progress' || 'active' => ConsultationStatus.active,
        'completed' || 'ended' => ConsultationStatus.ended,
        'cancelled' => ConsultationStatus.cancelled,
        _ => ConsultationStatus.scheduled,
      };

  // Combines DateOnly "2026-05-15" + TimeOnly "09:00:00" into DateTime.
  static DateTime _parseScheduledAt(String? date, String? time) {
    if (date == null) return DateTime.now();
    final datePart = date.split('T').first;
    final timePart = (time ?? '00:00:00').split('.').first;
    return DateTime.tryParse('${datePart}T$timePart') ?? DateTime.now();
  }
}
