import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/notifications_list_bloc.dart';
import '../bloc/notifications_list_event.dart';
import '../bloc/notifications_list_state.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationsListBloc>()
        .add(const NotificationPreferencesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notification Preferences', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationsListBloc, NotificationsListState>(
            builder: (_, state) {
              if (!state.isSavingPrefs) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: const CircularProgressIndicator(strokeWidth: 2)),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsListBloc, NotificationsListState>(
        builder: (context, state) {
          final prefs = state.preferences;
          if (prefs == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              _SectionHeader(label: 'Appointments'),
              _PrefTile(
                title: 'Appointment Reminders',
                subtitle: 'Push notifications for upcoming appointments',
                value: prefs.appointmentReminders,
                onChanged: (v) => _update(context, 'appointmentReminders', v),
              ),
              _PrefTile(
                title: 'SMS Reminders',
                subtitle: 'Receive appointment reminders via SMS',
                value: prefs.appointmentSms,
                onChanged: (v) => _update(context, 'appointmentSms', v),
              ),
              _SectionHeader(label: 'Queue'),
              _PrefTile(
                title: 'Queue Updates',
                subtitle: 'Notify when your turn is approaching',
                value: prefs.queueUpdates,
                onChanged: (v) => _update(context, 'queueUpdates', v),
              ),
              _SectionHeader(label: 'Health'),
              _PrefTile(
                title: 'Prediction Ready',
                subtitle: 'Notify when health predictions are available',
                value: prefs.predictionReady,
                onChanged: (v) => _update(context, 'predictionReady', v),
              ),
              _PrefTile(
                title: 'Medication Reminders',
                subtitle: 'Remind me to take medications on time',
                value: prefs.medicationReminders,
                onChanged: (v) => _update(context, 'medicationReminders', v),
              ),
              _SectionHeader(label: 'General'),
              _PrefTile(
                title: 'Promotional',
                subtitle: 'News, offers, and updates from MediMind',
                value: prefs.promotional,
                onChanged: (v) => _update(context, 'promotional', v),
              ),
            ],
          );
        },
      ),
    );
  }

  void _update(BuildContext context, String key, bool value) {
    context
        .read<NotificationsListBloc>()
        .add(NotificationPreferenceUpdated(key: key, value: value));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline,
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        title: Text(title, style: AppTypography.body),
        subtitle: Text(subtitle, style: AppTypography.caption),
      ),
    );
  }
}
