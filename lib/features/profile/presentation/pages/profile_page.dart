import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/delete_account_usecase.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../../auth/presentation/bloc/auth/auth_state.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../widgets/profile_section_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Returns the real display name; never surfaces "Patient" as if it were a name.
String _resolveDisplayName(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'User';
  if (raw.trim().toLowerCase() == 'patient') return 'User';
  return raw.trim();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
    _syncUserProfile();
  }

  Future<void> _syncUserProfile() async {
    try {
      final freshUser = await sl<ProfileRemoteDataSource>().getProfile();
      if (!mounted) return;
      context.read<AuthBloc>().add(UserLoggedIn(freshUser));
      sl<AuthRepository>().refreshCachedUser(freshUser);
    } catch (_) {}
  }

  Future<void> _deleteAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Account',
      message:
          'This action is irreversible. All your data will be permanently deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    final result = await sl<DeleteAccountUsecase>()();
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.danger,
        ),
      ),
      (_) => context.read<AuthBloc>().add(const UserLoggedOut()),
    );
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.read<AuthBloc>().add(const UserLoggedOut());
    }
  }

  void _showThemePicker(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: settingsBloc,
        child: const _ThemePickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is Authenticated ? authState.user : null;
        final displayName = _resolveDisplayName(user?.fullName);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            title: Text(
              displayName,
              style: AppTypography.subtitle,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header card ─────────────────────────────────────
                _ProfileHeader(
                  fullName: displayName,
                  phoneNumber: user?.phoneNumber ?? '',
                  avatarUrl: user?.profileImageUrl,
                  onEditTap: () =>
                      context.pushNamed(RouteNames.editProfile),
                ),
                SizedBox(height: 20.h),

                // ── My Health section ─────────────────────────────
                _Section(
                  title: 'My Health',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Info',
                      onTap: () =>
                          context.pushNamed(RouteNames.editProfile),
                    ),
                    ProfileSectionItem(
                      icon: Icons.history_rounded,
                      label: 'Medical History',
                      onTap: () =>
                          context.pushNamed(RouteNames.medicalHistory),
                    ),
                    ProfileSectionItem(
                      icon: Icons.emergency_outlined,
                      label: 'Emergency Contacts',
                      onTap: () =>
                          context.pushNamed(RouteNames.emergencyContacts),
                    ),
                    ProfileSectionItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Payment History',
                      onTap: () =>
                          context.pushNamed(RouteNames.paymentHistory),
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Preferences section ──────────────────────────
                _Section(
                  title: 'Preferences',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      onTap: () {
                        final isEn = context.locale.languageCode == 'en';
                        context.setLocale(
                          isEn
                              ? const Locale('am', 'ET')
                              : const Locale('en', 'US'),
                        );
                      },
                      trailing: Builder(
                        builder: (ctx) => Text(
                          ctx.locale.languageCode == 'en'
                              ? 'English'
                              : 'አማርኛ',
                          style: AppTypography.body
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    ProfileSectionItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Theme',
                      onTap: () => _showThemePicker(context),
                      trailing: BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (_, s) => Text(
                          switch (s.themeMode) {
                            ThemeMode.light => 'Light',
                            ThemeMode.dark => 'Dark',
                            ThemeMode.system => 'System',
                          },
                          style: AppTypography.body
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Support section ─────────────────────────────
                _Section(
                  title: 'Support',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.help_outline_rounded,
                      label: 'FAQ',
                      onTap: () {},
                    ),
                    ProfileSectionItem(
                      icon: Icons.mail_outline_rounded,
                      label: 'Contact Us',
                      onTap: () => launchUrl(
                        Uri.parse('mailto:support@medimind.et'),
                      ),
                    ),
                    ProfileSectionItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Terms & Privacy',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Security section ─────────────────────────
                _Section(
                  title: 'Security',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.fingerprint,
                      label: 'Biometric Login',
                      onTap: () {},
                      trailing: _ComingSoonBadge(),
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Account section ───────────────────────────
                _Section(
                  title: 'Account',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.delete_outline,
                      label: 'Delete Account',
                      onTap: _deleteAccount,
                      isDestructive: true,
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Log out ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.neutral300),
                    ),
                    child: ProfileSectionItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      onTap: _logout,
                      isDestructive: true,
                      showDivider: false,
                      trailing: const SizedBox.shrink(),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Version ─────────────────────────────────────
                if (_appVersion.isNotEmpty)
                  Text(
                    'MediMind v$_appVersion',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Profile Header ────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.phoneNumber,
    required this.onEditTap,
    this.avatarUrl,
  });

  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final VoidCallback onEditTap;

  String get _initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 16.w, 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      _initials,
                      style: AppTypography.title.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),

          // ── Name + phone ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phoneNumber.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    phoneNumber,
                    style: AppTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Edit button ────────────────────────────────────────
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18.r,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coming Soon badge ─────────────────────────────────────────────────────

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
      child: Text(
        'Coming Soon',
        style: AppTypography.overline.copyWith(color: AppColors.info),
      ),
    );
  }
}

// ─── Section container ─────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: AppColors.neutral500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}

// ─── Theme picker bottom sheet ─────────────────────────────────────────────

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Choose Theme', style: AppTypography.subtitle),
                SizedBox(height: 4.h),
                Text(
                  'Select how MediMind appears to you',
                  style: AppTypography.body
                      .copyWith(color: AppColors.neutral500),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {state.themeMode},
                    onSelectionChanged: (s) {
                      context
                          .read<SettingsBloc>()
                          .add(SettingsThemeModeChanged(s.first));
                    },
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
