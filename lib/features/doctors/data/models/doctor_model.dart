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

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        specialization: json['specialization'] as String? ?? '',
        yearsExperience: (json['yearsExperience'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        patientsSeen: (json['patientsSeen'] as num?)?.toInt() ?? 0,
        consultationFee:
            (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
        languages: (json['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        qualifications: (json['qualifications'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        centerIds: (json['centerIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        bio: json['bio'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        nextAvailableLabel: json['nextAvailableLabel'] as String?,
      );
}
