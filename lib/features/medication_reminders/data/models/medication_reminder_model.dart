import '../../domain/entities/medication_reminder.dart';

const _freqMap = {
  'once': ReminderFrequency.once,
  'twice': ReminderFrequency.twice,
  'threeTimes': ReminderFrequency.threeTimes,
  'fourTimes': ReminderFrequency.fourTimes,
  'custom': ReminderFrequency.custom,
};

const _freqReverseMap = {
  ReminderFrequency.once: 'once',
  ReminderFrequency.twice: 'twice',
  ReminderFrequency.threeTimes: 'threeTimes',
  ReminderFrequency.fourTimes: 'fourTimes',
  ReminderFrequency.custom: 'custom',
};

class MedicationReminderModel extends MedicationReminder {
  const MedicationReminderModel({
    required super.id,
    required super.medicationName,
    required super.dosage,
    required super.frequency,
    required super.times,
    required super.isActive,
    required super.startDate,
    super.endDate,
    super.notes,
    super.notificationIds,
  });

  factory MedicationReminderModel.fromJson(Map<String, dynamic> json) =>
      MedicationReminderModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        medicationName: json['medicationName'] as String,
        dosage: json['dosage'] as String,
        frequency:
            _freqMap[json['frequency'] as String?] ?? ReminderFrequency.once,
        times: (json['reminderTimes'] as List<dynamic>? ?? [])
            .map((t) => t as String)
            .toList(),
        isActive: json['isActive'] as bool? ?? true,
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        notes: json['notes'] as String?,
        notificationIds: (json['notificationIds'] as List<dynamic>? ?? [])
            .map((n) => n as int)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'medicationName': medicationName,
        'dosage': dosage,
        'frequency': _freqReverseMap[frequency],
        'reminderTimes': times,
        'isActive': isActive,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (notes != null) 'notes': notes,
        'notificationIds': notificationIds,
      };
}
