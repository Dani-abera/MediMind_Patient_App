import 'package:equatable/equatable.dart';

enum ReminderFrequency { once, twice, threeTimes, fourTimes, custom }

class MedicationReminder extends Equatable {
  const MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.isActive,
    required this.startDate,
    this.endDate,
    this.notes,
    this.notificationIds = const [],
  });

  final String id;
  final String medicationName;
  final String dosage;
  final ReminderFrequency frequency;
  final List<String> times;    // "HH:mm" strings, e.g. ["08:00", "20:00"]
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final List<int> notificationIds;

  String get frequencyLabel => switch (frequency) {
        ReminderFrequency.once => 'Once daily',
        ReminderFrequency.twice => 'Twice daily',
        ReminderFrequency.threeTimes => 'Three times daily',
        ReminderFrequency.fourTimes => 'Four times daily',
        ReminderFrequency.custom => 'Custom',
      };

  String get timesLabel {
    if (times.isEmpty) return '';
    if (times.length == 1) return _fmt(times.first);
    return times.map(_fmt).join(' · ');
  }

  String _fmt(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  MedicationReminder copyWith({
    bool? isActive,
    String? medicationName,
    String? dosage,
    ReminderFrequency? frequency,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    List<int>? notificationIds,
  }) =>
      MedicationReminder(
        id: id,
        medicationName: medicationName ?? this.medicationName,
        dosage: dosage ?? this.dosage,
        frequency: frequency ?? this.frequency,
        times: times ?? this.times,
        isActive: isActive ?? this.isActive,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        notes: notes ?? this.notes,
        notificationIds: notificationIds ?? this.notificationIds,
      );

  @override
  List<Object?> get props => [id, medicationName, dosage, frequency, times, isActive];
}
