import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.patientId,
    required this.fullName,
    required this.phoneNumber,
    required this.isProfileComplete,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.profileImageUrl,
    this.createdAt,
  });

  final String patientId;
  final String fullName;
  final String phoneNumber;
  final bool isProfileComplete;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profileImageUrl;
  final DateTime? createdAt;

  User copyWith({
    String? patientId,
    String? fullName,
    String? phoneNumber,
    bool? isProfileComplete,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        patientId,
        fullName,
        phoneNumber,
        isProfileComplete,
        email,
        dateOfBirth,
        gender,
        profileImageUrl,
        createdAt,
      ];
}
