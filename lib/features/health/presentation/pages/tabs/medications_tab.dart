import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/routing/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../medication_reminders/domain/entities/medication_reminder.dart';
import '../../../../medication_reminders/presentation/bloc/medication_reminders_bloc.dart';
import '../../../../medication_reminders/presentation/bloc/medication_reminders_event.dart';
import '../../../../medication_reminders/presentation/bloc/medication_reminders_state.dart';

class MedicationsTab extends StatelessWidget {
  const MedicationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationRemindersBloc, MedicationRemindersState>(
      builder: (context, state) {
        return switch (state) {
          MedicationRemindersInitial() ||
          MedicationRemindersLoading() =>
            const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            ),
          MedicationRemindersFailure(:final message) => Center(
              child: Text(message),
            ),
          MedicationRemindersLoaded(:final reminders) =>
            _MedicationsContent(reminders: reminders),
          MedicationReminderActionSuccess(:final reminders) =>
            _MedicationsContent(reminders: reminders),
          _ => const _MedicationsContent(reminders: []),
        };
      },
    );
  }
}

class _MedicationsContent extends StatelessWidget {
  const _MedicationsContent({required this.reminders});
  final List<MedicationReminder> reminders;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${reminders.length} medication${reminders.length == 1 ? '' : 's'}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(RouteNames.addReminder),
                  icon: Icon(Icons.add, size: 16.r),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (reminders.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined,
                      size: 64.r, color: AppColors.neutral300),
                  SizedBox(height: 16.h),
                  Text('No medications yet', style: AppTypography.subtitle),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap "Add" to set up your first\nmedication reminder',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ReminderCard(
                reminder: reminders[index],
              ),
              childCount: reminders.length,
            ),
          ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});
  final MedicationReminder reminder;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        color: AppColors.danger,
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.r),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text('Remove ${reminder.medicationName}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: TextStyle(color: AppColors.danger))),
          ],
        ),
      ),
      onDismissed: (_) => context
          .read<MedicationRemindersBloc>()
          .add(MedicationReminderDeleted(reminder.id)),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.medication,
                    color: AppColors.primary, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.medicationName,
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600)),
                    Text(reminder.dosage,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.neutral500)),
                    SizedBox(height: 4.h),
                    Text(
                      '${reminder.frequencyLabel} · ${reminder.timesLabel}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral700),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => context
                    .read<MedicationRemindersBloc>()
                    .add(MedicationReminderToggled(reminder.id)),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.danger, size: 20.r),
                tooltip: 'Delete',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Reminder'),
                      content: Text('Remove ${reminder.medicationName}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Delete',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context
                        .read<MedicationRemindersBloc>()
                        .add(MedicationReminderDeleted(reminder.id));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
