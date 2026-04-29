import 'package:equatable/equatable.dart';

enum AllergenSeverity { mild, moderate, severe }
enum AlcoholConsumption { none, occasional, regular }

class Allergy extends Equatable {
  const Allergy({
    required this.allergen,
    required this.severity,
    this.notes,
  });
  final String allergen;
  final AllergenSeverity severity;
  final String? notes;

  Allergy copyWith({String? allergen, AllergenSeverity? severity, String? notes}) =>
      Allergy(
        allergen: allergen ?? this.allergen,
        severity: severity ?? this.severity,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [allergen, severity, notes];
}

class CurrentMedication extends Equatable {
  const CurrentMedication({
    required this.name,
    required this.dosage,
    required this.startedDate,
  });
  final String name;
  final String dosage;
  final DateTime startedDate;

  @override
  List<Object?> get props => [name, dosage, startedDate];
}

class MedicalHistory extends Equatable {
  const MedicalHistory({
    this.bloodType,
    this.chronicConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.familyHistory = const [],
    this.isSmoker = false,
    this.alcoholConsumption = AlcoholConsumption.none,
  });

  final String? bloodType;
  final List<String> chronicConditions;
  final List<Allergy> allergies;
  final List<CurrentMedication> currentMedications;
  final List<String> familyHistory;
  final bool isSmoker;
  final AlcoholConsumption alcoholConsumption;

  MedicalHistory copyWith({
    String? bloodType,
    List<String>? chronicConditions,
    List<Allergy>? allergies,
    List<CurrentMedication>? currentMedications,
    List<String>? familyHistory,
    bool? isSmoker,
    AlcoholConsumption? alcoholConsumption,
  }) =>
      MedicalHistory(
        bloodType: bloodType ?? this.bloodType,
        chronicConditions: chronicConditions ?? this.chronicConditions,
        allergies: allergies ?? this.allergies,
        currentMedications: currentMedications ?? this.currentMedications,
        familyHistory: familyHistory ?? this.familyHistory,
        isSmoker: isSmoker ?? this.isSmoker,
        alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      );

  @override
  List<Object?> get props => [
        bloodType, chronicConditions, allergies, currentMedications,
        familyHistory, isSmoker, alcoholConsumption,
      ];
}
