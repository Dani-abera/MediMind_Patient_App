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
import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../../auth/presentation/bloc/auth/auth_state.dart';
import '../widgets/profile_section_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user =
              authState is Authenticated ? authState.user : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header card ─────────────────────────────────────
                _ProfileHeader(
                  fullName: user?.fullName ?? '',
                  phoneNumber: user?.phoneNumber ?? '',
                  avatarUrl: user?.profileImageUrl,
                  onEditTap: () =>
                      context.pushNamed(RouteNames.editProfile),
                ),
                SizedBox(height: 16.h),

                // ── Personal section ────────────────────────────────
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
                      onTap: () {},
                    ),
                    ProfileSectionItem(
                      icon: Icons.emergency_outlined,
                      label: 'Emergency Contacts',
                      onTap: () {},
                    ),
                    ProfileSectionItem(
                      icon: Icons.payment_rounded,
                      label: 'Payment History',
                      onTap: () =>
                          context.pushNamed(RouteNames.paymentMethods),
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                _Section(
                  title: 'Preferences',
                  items: [
                    ProfileSectionItem(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      onTap: () {
                        final isEn =
                            context.locale.languageCode == 'en';
                        context.setLocale(
                          isEn
                              ? const Locale('am', 'ET')
                              : const Locale('en', 'US'),
                        );
                      },
                      trailing: BlocBuilder<AuthBloc, AuthState>(
                        builder: (ctx, _) => Text(
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
                      onTap: () =>
                          context.pushNamed(RouteNames.settings),
                      showDivider: false,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

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
                        Uri.parse(
                            'mailto:support@medimind.et'),
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

                // ── Logout ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.neutral300),
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

                // ── Version ─────────────────────────────────────────
                if (_appVersion.isNotEmpty)
                  Text(
                    'MediMind v$_appVersion',
                    style: AppTypography.caption,
                  ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final initials = fullName.isNotEmpty
        ? fullName.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: AppColors.primaryLight,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: AppTypography.title.copyWith(
                      color: AppColors.white,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: AppTypography.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phoneNumber,
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEditTap,
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

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
              color: AppColors.white,
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
