import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.yearsExperience,
    required this.rating,
    required this.reviewCount,
    required this.patientsSeen,
    required this.consultationFee,
    required this.languages,
    required this.qualifications,
    required this.centerIds,
    this.bio,
    this.avatarUrl,
    this.nextAvailableLabel,
  });

  final String id;
  final String fullName;
  final String specialization;
  final int yearsExperience;
  final double rating;
  final int reviewCount;
  final int patientsSeen;
  final double consultationFee;
  final List<String> languages;
  final List<String> qualifications;
  final List<String> centerIds;
  final String? bio;
  final String? avatarUrl;
  final String? nextAvailableLabel;

  String get formattedFee => 'ETB ${consultationFee.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id, fullName, specialization, yearsExperience,
        rating, reviewCount, consultationFee,
      ];
}
