import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/medication_reminder.dart';
import '../bloc/medication_reminders_bloc.dart';
import '../bloc/medication_reminders_event.dart';
import '../bloc/medication_reminders_state.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  ReminderFrequency _frequency = ReminderFrequency.once;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];

  static const _frequencyOptions = [
    (ReminderFrequency.once, 'Once daily', 1),
    (ReminderFrequency.twice, 'Twice daily', 2),
    (ReminderFrequency.threeTimes, 'Three times daily', 3),
    (ReminderFrequency.fourTimes, 'Four times daily', 4),
    (ReminderFrequency.custom, 'Custom', 1),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setFrequency(ReminderFrequency freq) {
    final defaultCounts = {
      ReminderFrequency.once: 1,
      ReminderFrequency.twice: 2,
      ReminderFrequency.threeTimes: 3,
      ReminderFrequency.fourTimes: 4,
      ReminderFrequency.custom: _times.length,
    };
    final count = defaultCounts[freq]!;
    setState(() {
      _frequency = freq;
      if (freq != ReminderFrequency.custom) {
        _times = List.generate(
          count,
          (i) => TimeOfDay(hour: 8 + (i * (12 ~/ count)), minute: 0),
        );
      }
    });
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final times = _times.map(_timeToString).toList();
    context.read<MedicationRemindersBloc>().add(
          MedicationReminderAdded(
            medicationName: _nameController.text.trim(),
            dosage: _dosageController.text.trim(),
            frequency: _frequency,
            times: times,
            startDate: _startDate,
            endDate: _endDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationRemindersBloc, MedicationRemindersState>(
      listener: (context, state) {
        if (state is MedicationReminderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is MedicationRemindersFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Add Reminder', style: AppTypography.title),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: BlocBuilder<MedicationRemindersBloc,
            MedicationRemindersState>(
          builder: (context, state) {
            final isLoading = state is MedicationReminderAdding;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('Medication'),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDeco('Medication Name',
                          'e.g. Metformin'),
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _dosageController,
                      decoration: _inputDeco('Dosage', 'e.g. 500mg'),
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    SizedBox(height: 20.h),
                    _SectionHeader('Frequency'),
                    DropdownButtonFormField<ReminderFrequency>(
                      // ignore: deprecated_member_use
                      value: _frequency,
                      decoration: _inputDeco('Frequency', ''),
                      items: _frequencyOptions
                          .map((opt) => DropdownMenuItem(
                                value: opt.$1,
                                child: Text(opt.$2),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          v != null ? _setFrequency(v) : null,
                    ),
                    SizedBox(height: 20.h),
                    _SectionHeader('Reminder Times'),
                    ..._times.asMap().entries.map((entry) {
                      final i = entry.key;
                      final t = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickTime(i),
                                icon: Icon(Icons.access_time, size: 18.r),
                                label: Text(t.format(context)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                      color: AppColors.neutral300),
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                ),
                              ),
                            ),
                            if (_frequency ==
                                    ReminderFrequency.custom &&
                                _times.length > 1) ...[
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: AppColors.danger, size: 20.r),
                                onPressed: () => setState(
                                    () => _times.removeAt(i)),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    if (_frequency == ReminderFrequency.custom)
                      TextButton.icon(
                        onPressed: () => setState(() => _times.add(
                            const TimeOfDay(hour: 12, minute: 0))),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Time'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                      ),
                    SizedBox(height: 20.h),
                    _SectionHeader('Schedule'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickDate(isStart: true),
                            icon: Icon(Icons.calendar_today, size: 16.r),
                            label: Text(
                                _formatDate(_startDate),
                                style: AppTypography.caption),
                            style: _dateButtonStyle(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickDate(isStart: false),
                            icon: Icon(Icons.event, size: 16.r),
                            label: Text(
                              _endDate != null
                                  ? _formatDate(_endDate!)
                                  : 'No end date',
                              style: AppTypography.caption,
                            ),
                            style: _dateButtonStyle(),
                          ),
                        ),
                        if (_endDate != null)
                          IconButton(
                            icon: Icon(Icons.close, size: 18.r),
                            onPressed: () =>
                                setState(() => _endDate = null),
                            color: AppColors.neutral500,
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration:
                          _inputDeco('Notes (optional)', 'Take with food...'),
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Reminder'),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.white,
      );

  ButtonStyle _dateButtonStyle() => OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral700,
        side: BorderSide(color: AppColors.neutral300),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
      );

  String _formatDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.neutral700,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
