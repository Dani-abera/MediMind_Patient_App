import 'dart:convert';
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
      chronicConditions: _parseStringList(json['chronicConditions']),
      allergies: _parseAllergies(json['allergies']),
      currentMedications: _parseMedications(json['currentMedications']),
      familyHistory: _parseStringList(json['familyHistory']),
      isSmoker: (json['smoker'] ?? json['isSmoker']) as bool? ?? false,
      alcoholConsumption:
          _parseAlcohol(json['alcoholConsumption'] as String? ?? ''),
    );
  }

  // The backend stores these fields as JSON strings (e.g. "[]", "[{...}]").
  // Serialize arrays → JSON-encoded strings so the backend can store them directly.
  Map<String, dynamic> toJson() => {
        if (bloodType != null) 'bloodType': bloodType,
        'chronicConditions': jsonEncode(chronicConditions),
        'allergies': jsonEncode(
          allergies
              .map((a) => {
                    'allergen': a.allergen,
                    'severity': a.severity.name,
                    if (a.notes != null) 'notes': a.notes,
                  })
              .toList(),
        ),
        'currentMedications': jsonEncode(
          currentMedications
              .map((m) => {
                    'name': m.name,
                    'dosage': m.dosage,
                    'startedDate': m.startedDate.toIso8601String(),
                  })
              .toList(),
        ),
        'familyHistory': jsonEncode(familyHistory),
        'smoker': isSmoker,
        'alcoholConsumption': alcoholConsumption.name,
      };

  // Handles both native List (unlikely) and JSON-string from backend.
  static List<String> _parseStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    if (val is String && val.isNotEmpty) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return [];
  }

  static List<Allergy> _parseAllergies(dynamic val) {
    List<dynamic>? list;
    if (val is List) {
      list = val;
    } else if (val is String && val.isNotEmpty) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) list = decoded;
      } catch (_) {}
    }
    if (list == null) return [];
    return list.map((a) {
      final m = a as Map<String, dynamic>;
      return Allergy(
        allergen: m['allergen'] as String,
        severity: _parseSeverity(m['severity'] as String? ?? ''),
        notes: m['notes'] as String?,
      );
    }).toList();
  }

  static List<CurrentMedication> _parseMedications(dynamic val) {
    List<dynamic>? list;
    if (val is List) {
      list = val;
    } else if (val is String && val.isNotEmpty) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) list = decoded;
      } catch (_) {}
    }
    if (list == null) return [];
    return list.map((m) {
      final med = m as Map<String, dynamic>;
      return CurrentMedication(
        name: med['name'] as String,
        dosage: med['dosage'] as String? ?? '',
        startedDate: med['startedDate'] != null
            ? DateTime.parse(med['startedDate'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

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
