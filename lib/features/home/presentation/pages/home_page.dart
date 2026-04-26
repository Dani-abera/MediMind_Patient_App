import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_state.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/greeting_header.dart';
import '../widgets/nearby_centers_section.dart';
import '../widgets/prediction_teaser.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../widgets/vitals_summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeOpened());
    context
        .read<NotificationBloc>()
        .add(const NotificationPollingStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return _HomeShimmer();
            }
            if (state is HomeError) {
              return _HomeError(
                message: state.message,
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeRefreshed()),
              );
            }

            final data = switch (state) {
              HomeLoaded(data: final d) => d,
              HomePartialLoaded(data: final d) => d,
              _ => null,
            };

            if (data == null) return const SizedBox.shrink();

            final user = context.read<AuthBloc>().state;
            final userName = user is Authenticated
                ? user.user.fullName
                : 'there';
            final avatarUrl = user is Authenticated
                ? user.user.profileImageUrl
                : null;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<HomeBloc>()
                    .add(const HomeRefreshed());
                await context.read<HomeBloc>().stream.firstWhere(
                      (s) => s is! HomeLoading,
                    );
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        GreetingHeader(
                          fullName: userName,
                          avatarUrl: avatarUrl,
                        ),
                        SizedBox(height: 24.h),
                        if (data.upcomingAppointment != null) ...[
                          UpcomingAppointmentCard(
                            appointment: data.upcomingAppointment!,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            'Quick Actions',
                            style: AppTypography.subtitle,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        const QuickActionsGrid(),
                        SizedBox(height: 24.h),
                        VitalsSummaryCard(
                          healthRecord: data.latestHealthRecord,
                        ),
                        SizedBox(height: 24.h),
                        if (data.latestPrediction != null) ...[
                          PredictionTeaser(
                            prediction: data.latestPrediction!,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        NearbyCentersSection(
                          centers: data.nearbyCenters,
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.line(width: 180.w, height: 22),
                    SizedBox(height: 8.h),
                    AppShimmer.line(width: 120.w),
                  ],
                ),
              ),
              AppShimmer.circle(size: 40.w),
            ],
          ),
          SizedBox(height: 24.h),
          AppShimmer.box(width: double.infinity, height: 140.h, radius: 16),
          SizedBox(height: 24.h),
          AppShimmer.box(width: double.infinity, height: 140.h, radius: 16),
          SizedBox(height: 24.h),
          AppShimmer.box(width: double.infinity, height: 100.h, radius: 16),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text(message, style: AppTypography.body, textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
