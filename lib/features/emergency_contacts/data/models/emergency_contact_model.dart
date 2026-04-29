import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.id,
    required super.fullName,
    required super.relationship,
    required super.phoneNumber,
    super.isPrimary,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      EmergencyContactModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        fullName: json['fullName'] as String,
        relationship: json['relationship'] as String,
        phoneNumber: json['phoneNumber'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'relationship': relationship,
        'phoneNumber': phoneNumber,
        'isPrimary': isPrimary,
      };
}
