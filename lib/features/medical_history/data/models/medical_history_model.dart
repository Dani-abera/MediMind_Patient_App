import '../../domain/entities/medical_history.dart';

class MedicalHistoryModel extends MedicalHistory {
  const MedicalHistoryModel({
    super.bloodType,
    super.chronicConditions,
    super.allergies,
    super.currentMedications,
    super.familyHistory,
    super.isSmoker,
    super.alcoholConsumption,
  });

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryModel(
      bloodType: json['bloodType'] as String?,
      chronicConditions: (json['chronicConditions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      allergies: (json['allergies'] as List<dynamic>? ?? [])
          .map((a) {
            final m = a as Map<String, dynamic>;
            return Allergy(
              allergen: m['allergen'] as String,
              severity: _parseSeverity(m['severity'] as String? ?? ''),
              notes: m['notes'] as String?,
            );
          })
          .toList(),
      currentMedications:
          (json['currentMedications'] as List<dynamic>? ?? []).map((m) {
        final med = m as Map<String, dynamic>;
        return CurrentMedication(
          name: med['name'] as String,
          dosage: med['dosage'] as String? ?? '',
          startedDate: med['startedDate'] != null
              ? DateTime.parse(med['startedDate'] as String)
              : DateTime.now(),
        );
      }).toList(),
      familyHistory: (json['familyHistory'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      isSmoker: json['isSmoker'] as bool? ?? false,
      alcoholConsumption:
          _parseAlcohol(json['alcoholConsumption'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        if (bloodType != null) 'bloodType': bloodType,
        'chronicConditions': chronicConditions,
        'allergies': allergies
            .map((a) => {
                  'allergen': a.allergen,
                  'severity': a.severity.name,
                  if (a.notes != null) 'notes': a.notes,
                })
            .toList(),
        'currentMedications': currentMedications
            .map((m) => {
                  'name': m.name,
                  'dosage': m.dosage,
                  'startedDate': m.startedDate.toIso8601String(),
                })
            .toList(),
        'familyHistory': familyHistory,
        'isSmoker': isSmoker,
        'alcoholConsumption': alcoholConsumption.name,
      };

  static AllergenSeverity _parseSeverity(String s) =>
      switch (s.toLowerCase()) {
        'moderate' => AllergenSeverity.moderate,
        'severe' => AllergenSeverity.severe,
        _ => AllergenSeverity.mild,
      };

  static AlcoholConsumption _parseAlcohol(String s) =>
      switch (s.toLowerCase()) {
        'occasional' => AlcoholConsumption.occasional,
        'regular' => AlcoholConsumption.regular,
        _ => AlcoholConsumption.none,
      };
}
