import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../domain/entities/appointment_detail.dart';
import '../bloc/appointments/appointments_bloc.dart';
import '../bloc/appointments/appointments_event.dart';
import '../bloc/appointments/appointments_state.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AppointmentsBloc>().add(const AppointmentsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const _AppointmentsShimmer();
          }
          if (state is AppointmentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTypography.body),
                  TextButton(
                    onPressed: () => context
                        .read<AppointmentsBloc>()
                        .add(const AppointmentsRefreshed()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loaded =
              state is AppointmentsLoaded ? state : null;
          final upcoming = loaded?.upcoming ?? [];
          final past = loaded?.past ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AppointmentsBloc>()
                  .add(const AppointmentsRefreshed());
              await context
                  .read<AppointmentsBloc>()
                  .stream
                  .firstWhere((s) =>
                      s is AppointmentsLoaded || s is AppointmentsError);
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _AppointmentsList(
                  appointments: upcoming,
                  empty: 'No upcoming appointments.',
                  emptyAction: () =>
                      context.push('/book/search'),
                ),
                _AppointmentsList(appointments: past, empty: 'No past appointments.'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book/search'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Book',
            style:
                AppTypography.body.copyWith(color: AppColors.white)),
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({
    required this.appointments,
    required this.empty,
    this.emptyAction,
  });

  final List<AppointmentDetail> appointments;
  final String empty;
  final VoidCallback? emptyAction;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48.r, color: AppColors.neutral300),
            SizedBox(height: 12.h),
            Text(empty, style: AppTypography.body),
            if (emptyAction != null) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: emptyAction,
                child: const Text('Book one'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) => _AppointmentCard(
        appointment: appointments[i],
        onTap: () => context.pushNamed(
          RouteNames.appointmentDetail,
          pathParameters: {'id': appointments[i].id},
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  final AppointmentDetail appointment;
  final VoidCallback onTap;

  Color get _statusColor => switch (appointment.status) {
        AppointmentStatus.pending => AppColors.warning,
        AppointmentStatus.confirmed => AppColors.success,
        AppointmentStatus.inProgress => AppColors.info,
        AppointmentStatus.completed => AppColors.neutral500,
        AppointmentStatus.cancelled => AppColors.danger,
        AppointmentStatus.noShow => AppColors.neutral500,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(
                  label: appointment.statusLabel,
                  color: _statusColor,
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.neutral500),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: appointment.doctorAvatarUrl != null
                      ? NetworkImage(appointment.doctorAvatarUrl!)
                      : null,
                  child: appointment.doctorAvatarUrl == null
                      ? Text(
                          appointment.doctorName.isNotEmpty
                              ? appointment.doctorName[0].toUpperCase()
                              : '?',
                          style: AppTypography.body
                              .copyWith(color: AppColors.white),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${appointment.doctorName}',
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        appointment.doctorSpecialization,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.neutral500),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    appointment.centerName,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  DateFormat('EEE, MMM d · h:mm a')
                      .format(appointment.appointmentTime),
                  style: AppTypography.body.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (appointment.queueNumber != null) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  const Icon(Icons.people_outline_rounded,
                      size: 14, color: AppColors.info),
                  SizedBox(width: 4.w),
                  Text(
                    'Queue #${appointment.queueNumber}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AppointmentsShimmer extends StatelessWidget {
  const _AppointmentsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AppShimmer.box(
                width: double.infinity, height: 120.h, radius: 12),
          ),
        ),
      ),
    );
  }
}
