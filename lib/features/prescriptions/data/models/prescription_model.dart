import '../../domain/entities/prescription.dart';

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.id,
    required super.referenceNumber,
    required super.issuedAt,
    required super.expiryDate,
    required super.status,
    required super.doctorName,
    required super.doctorSpecialty,
    required super.diagnosis,
    required super.medications,
    super.labTests,
    super.followUpInstructions,
    super.qrCodeBase64,
    super.appointmentId,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      referenceNumber: json['referenceNumber'] as String? ?? '',
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: _parseStatus(json['status'] as String? ?? ''),
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpecialty: json['doctorSpecialty'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      medications: (json['medications'] as List<dynamic>? ?? [])
          .map((m) => _parseMedication(m as Map<String, dynamic>))
          .toList(),
      labTests: (json['labTests'] as List<dynamic>? ?? [])
          .map((t) => PrescriptionLabTest(
                testName: (t as Map<String, dynamic>)['testName'] as String,
                notes: t['notes'] as String?,
              ))
          .toList(),
      followUpInstructions: json['followUpInstructions'] as String?,
      qrCodeBase64: json['qrCode'] as String?,
      appointmentId: json['appointmentId'] as String?,
    );
  }

  static PrescriptionStatus _parseStatus(String s) =>
      switch (s.toLowerCase()) {
        'expired' => PrescriptionStatus.expired,
        'dispensed' => PrescriptionStatus.dispensed,
        _ => PrescriptionStatus.active,
      };

  static PrescriptionMedication _parseMedication(Map<String, dynamic> m) =>
      PrescriptionMedication(
        name: m['name'] as String,
        dosage: m['dosage'] as String? ?? '',
        frequency: m['frequency'] as String? ?? '',
        durationDays: (m['durationDays'] as num?)?.toInt() ?? 0,
        instructions: m['instructions'] as String?,
        times: (m['times'] as List<dynamic>? ?? [])
            .map((t) => t as String)
            .toList(),
      );
}
