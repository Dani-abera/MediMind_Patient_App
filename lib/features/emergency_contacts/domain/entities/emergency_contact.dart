import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  const EmergencyContact({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
    this.isPrimary = false,
  });

  final String id;
  final String fullName;
  final String relationship;
  final String phoneNumber;
  final bool isPrimary;

  EmergencyContact copyWith({
    String? id,
    String? fullName,
    String? relationship,
    String? phoneNumber,
    bool? isPrimary,
  }) =>
      EmergencyContact(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        relationship: relationship ?? this.relationship,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        isPrimary: isPrimary ?? this.isPrimary,
      );

  @override
  List<Object?> get props =>
      [id, fullName, relationship, phoneNumber, isPrimary];
}
