import 'package:equatable/equatable.dart';

enum PrescriptionStatus { active, expired, dispensed }

class PrescriptionMedication extends Equatable {
  const PrescriptionMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    this.instructions,
    this.times = const [],
  });
  final String name;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String? instructions;
  final List<String> times;

  @override
  List<Object?> get props =>
      [name, dosage, frequency, durationDays, instructions, times];
}

class PrescriptionLabTest extends Equatable {
  const PrescriptionLabTest({required this.testName, this.notes});
  final String testName;
  final String? notes;
  @override
  List<Object?> get props => [testName, notes];
}

class Prescription extends Equatable {
  const Prescription({
    required this.id,
    required this.referenceNumber,
    required this.issuedAt,
    required this.expiryDate,
    required this.status,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.diagnosis,
    required this.medications,
    this.labTests = const [],
    this.followUpInstructions,
    this.qrCodeBase64,
    this.appointmentId,
  });

  final String id;
  final String referenceNumber;
  final DateTime issuedAt;
  final DateTime expiryDate;
  final PrescriptionStatus status;
  final String doctorName;
  final String doctorSpecialty;
  final String diagnosis;
  final List<PrescriptionMedication> medications;
  final List<PrescriptionLabTest> labTests;
  final String? followUpInstructions;
  final String? qrCodeBase64;
  final String? appointmentId;

  @override
  List<Object?> get props => [
        id, referenceNumber, issuedAt, expiryDate, status,
        doctorName, doctorSpecialty, diagnosis, medications,
        labTests, followUpInstructions, qrCodeBase64, appointmentId,
      ];
}
