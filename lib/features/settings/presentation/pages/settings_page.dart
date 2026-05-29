import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.accountDeleted) {
            context.read<AuthBloc>().add(const UserLoggedOut());
            context.go('/');
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              _SectionHeader(label: 'Appearance'),
              _ThemeTile(
                current: state.themeMode,
                onChanged: (m) => context
                    .read<SettingsBloc>()
                    .add(SettingsThemeModeChanged(m)),
              ),
              _SectionHeader(label: 'Notifications'),
              _NavTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Preferences',
                onTap: () =>
                    context.pushNamed(RouteNames.notificationPreferences),
              ),
              _SectionHeader(label: 'Security'),
              _NavTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                trailing: const _ComingSoonBadge(),
                onTap: () {},
              ),
              _SectionHeader(label: 'Support'),
              _NavTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.info_outline_rounded,
                title: 'About MediMind',
                trailing: Text('v1.0.0',
                    style: AppTypography.caption),
                onTap: () {},
              ),
              _SectionHeader(label: 'Account'),
              _NavTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                onTap: () => _confirmDeleteAccount(context, state),
                textColor: AppColors.danger,
              ),
              SizedBox(height: 32.h),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, SettingsState state) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This action is irreversible. All your data will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: state.isLoading
                ? null
                : () {
                    Navigator.pop(context);
                    context
                        .read<SettingsBloc>()
                        .add(const SettingsAccountDeleteRequested());
                  },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: state.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
      child: Text(label.toUpperCase(), style: AppTypography.overline),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.textColor,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.neutral900;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20.sp, color: color),
        title: Text(title,
            style: AppTypography.body.copyWith(color: color)),
        trailing: trailing ??
            Icon(Icons.chevron_right,
                size: 20.sp, color: AppColors.neutral500),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile(
      {required this.current, required this.onChanged});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  size: 20.sp, color: AppColors.neutral900),
              SizedBox(width: 12.w),
              Text('Theme', style: AppTypography.body),
            ],
          ),
          SizedBox(height: 8.h),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined)),
            ],
            selected: {current},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text('Coming Soon',
          style: AppTypography.overline.copyWith(color: AppColors.info)),
    );
  }
}

