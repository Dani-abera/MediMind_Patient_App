import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.fullName,
    required super.specialization,
    required super.yearsExperience,
    required super.rating,
    required super.reviewCount,
    required super.patientsSeen,
    required super.consultationFee,
    required super.languages,
    required super.qualifications,
    required super.centerIds,
    super.bio,
    super.avatarUrl,
    super.nextAvailableLabel,
  });

  static List<String> _parseQualifications(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    final str = value.toString().trim();
    if (str.isEmpty) return [];
    return str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final workingCenters =
        (json['workingCenters'] as List<dynamic>?)
            ?.map((e) => (e as Map<String, dynamic>)['centerId']?.toString())
            .whereType<String>()
            .toList();

    return DoctorModel(
      id: json['doctorId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      yearsExperience:
          (json['yearsOfExperience'] as num?)?.toInt() ??
          (json['yearsExperience'] as num?)?.toInt() ??
          0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      patientsSeen: (json['patientsSeen'] as num?)?.toInt() ?? 0,
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      languages: (json['languagesSpoken'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      qualifications: _parseQualifications(json['qualifications']),
      centerIds: workingCenters ??
          (json['centerIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bio: json['bio'] as String? ?? json['biography'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['profileImageUrl'] as String?,
      nextAvailableLabel: json['nextAvailableSlot'] as String? ??
          json['nextAvailableLabel'] as String?,
    );
  }
}
