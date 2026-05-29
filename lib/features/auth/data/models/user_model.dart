import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.patientId,
    required super.fullName,
    required super.phoneNumber,
    required super.isProfileComplete,
    super.email,
    super.dateOfBirth,
    super.gender,
    super.profileImageUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      patientId: json['patientId'] as String? ?? json['_id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      // PatientProfileDto (GET /auth/patient/profile) doesn't include
      // isProfileComplete — default to true since having a profile record means
      // registration already completed.
      isProfileComplete: json['isProfileComplete'] as bool? ?? true,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      profileImageUrl: () {
        final u = ApiConstants.resolveImageUrl(
            json['profileImageUrl'] as String?);
        return u.isEmpty ? null : u;
      }(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isProfileComplete': isProfileComplete,
      if (email != null) 'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      patientId: user.patientId,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      isProfileComplete: user.isProfileComplete,
      email: user.email,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
    );
  }
}
