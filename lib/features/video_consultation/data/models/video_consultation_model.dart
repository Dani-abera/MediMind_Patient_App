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
    return VideoConsultationModel(
      id: json['id'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      doctorAvatarUrl: json['doctorAvatarUrl'] as String? ?? '',
      status: _parseStatus(json['status'] as String),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  static ConsultationStatus _parseStatus(String s) =>
      switch (s.toLowerCase()) {
        'active' => ConsultationStatus.active,
        'ended' => ConsultationStatus.ended,
        'cancelled' => ConsultationStatus.cancelled,
        _ => ConsultationStatus.scheduled,
      };
}
