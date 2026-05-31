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

  factory DoctorModel.fromJson(Map<String, dynamic> json, {String? centerId}) {
    final workingCenters =
        (json['workingCenters'] as List<dynamic>?)
            ?.map((e) => (e as Map<String, dynamic>)['centerId']?.toString())
            .whereType<String>()
            .toList();

    double fee = (json['consultationFee'] as num?)?.toDouble() ?? 0.0;
    if (fee == 0.0 && centerId != null) {
      final centers = json['workingCenters'] as List<dynamic>?;
      if (centers != null) {
        for (final c in centers.whereType<Map<String, dynamic>>()) {
          if (c['centerId']?.toString() == centerId) {
            final f = (c['consultationFee'] as num?)?.toDouble();
            if (f != null && f > 0) {
              fee = f;
              break;
            }
          }
        }
      }
    }

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
      consultationFee: fee,
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
