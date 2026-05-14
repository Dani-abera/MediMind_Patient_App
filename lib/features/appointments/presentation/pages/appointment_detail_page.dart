import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../../video_consultation/domain/repositories/video_consultation_repository.dart';
import '../../domain/entities/appointment_detail.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import '../../domain/usecases/get_appointment_detail_usecase.dart';

class AppointmentDetailPage extends StatefulWidget {
  const AppointmentDetailPage({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  State<AppointmentDetailPage> createState() =>
      _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  AppointmentDetail? _detail;
  String? _error;
  bool _loading = true;
  bool _cancelling = false;
  bool _joiningCall = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _joinVideoCall(AppointmentDetail detail) async {
    // Fast path: consultationId already in appointment DTO
    if (detail.videoConsultationId != null) {
      context.pushNamed(RouteNames.videoCall,
          pathParameters: {'id': detail.videoConsultationId!});
      return;
    }
    // Slow path: look up consultation by appointmentId
    setState(() => _joiningCall = true);
    final repo = sl<VideoConsultationRepository>();
    final result =
        await repo.getConsultationByAppointmentId(detail.id);
    if (!mounted) return;
    setState(() => _joiningCall = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor hasn\'t started the call yet. Please wait.'),
          backgroundColor: AppColors.warning,
        ),
      ),
      (consultation) => context.pushNamed(RouteNames.videoCall,
          pathParameters: {'id': consultation.id}),
    );
  }

  Future<void> _load() async {
    final result =
        await sl<GetAppointmentDetailUsecase>()(widget.appointmentId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (d) => setState(() {
        _detail = d;
        _loading = false;
      }),
    );
  }

  Future<void> _cancel() async {
    final hours = _detail?.cancellationPolicyHours ?? 2;
    final policyNote = hours > 0
        ? 'Cancellation requires at least $hours hour${hours == 1 ? '' : 's'} notice.'
        : null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            if (policyNote != null) ...[
              const SizedBox(height: 8),
              Text(policyNote, style: AppTypography.caption),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Cancel Appointment',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    final result =
        await sl<CancelAppointmentUsecase>()(widget.appointmentId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() => _cancelling = false),
      (_) => context.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _DetailShimmer();
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: AppTypography.body),
              TextButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _load();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final d = _detail!;
    final statusColor = _statusColor(d.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Appointment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBanner(status: d.statusLabel, color: statusColor),
            SizedBox(height: 16.h),
            _DetailCard(
              title: 'Doctor',
              child: _DoctorInfo(detail: d),
            ),
            SizedBox(height: 12.h),
            _DetailCard(
              title: 'Center',
              child: _CenterInfo(detail: d),
            ),
            SizedBox(height: 12.h),
            _DetailCard(
              title: 'Date & Time',
              child: _DateTimeInfo(detail: d),
            ),
            if (d.queueNumber != null && d.isToday && d.isUpcoming) ...[
              SizedBox(height: 12.h),
              _QueueCard(detail: d),
            ],
            if (d.reasonForVisit != null) ...[
              SizedBox(height: 12.h),
              _DetailCard(
                title: 'Reason for Visit',
                child: Text(d.reasonForVisit!, style: AppTypography.body),
              ),
            ],
            SizedBox(height: 24.h),
            _ActionButtons(
              detail: d,
              cancelling: _cancelling,
              onCancel: _cancel,
              joiningCall: _joiningCall,
              onJoinCall: () => _joinVideoCall(d),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AppointmentStatus status) => switch (status) {
        AppointmentStatus.pending => AppColors.warning,
        AppointmentStatus.confirmed => AppColors.success,
        AppointmentStatus.completed => AppColors.neutral500,
        AppointmentStatus.cancelled => AppColors.danger,
        AppointmentStatus.noShow => AppColors.neutral500,
      };
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 20.r),
          SizedBox(width: 8.w),
          Text(
            status,
            style: AppTypography.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.overline
                .copyWith(color: AppColors.neutral500, letterSpacing: 1),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  const _DoctorInfo({required this.detail});
  final AppointmentDetail detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: detail.doctorAvatarUrl != null
              ? NetworkImage(detail.doctorAvatarUrl!)
              : null,
          child: detail.doctorAvatarUrl == null
              ? Text(detail.doctorName[0].toUpperCase(),
                  style:
                      AppTypography.body.copyWith(color: AppColors.white))
              : null,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${detail.doctorName}',
                style: AppTypography.body
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(detail.doctorSpecialization,
                style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

class _CenterInfo extends StatelessWidget {
  const _CenterInfo({required this.detail});
  final AppointmentDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(detail.centerName,
            style:
                AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 4.h),
        Text(detail.centerAddress, style: AppTypography.caption),
        SizedBox(height: 8.h),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => launchUrl(
                  Uri(scheme: 'tel', path: detail.centerPhone)),
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: const Text('Call'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary),
            ),
            if (detail.centerLatitude != null)
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(
                    'https://maps.google.com/?q=${detail.centerLatitude},${detail.centerLongitude}')),
                icon: const Icon(Icons.directions_outlined, size: 16),
                label: const Text('Directions'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
          ],
        ),
      ],
    );
  }
}

class _DateTimeInfo extends StatelessWidget {
  const _DateTimeInfo({required this.detail});
  final AppointmentDetail detail;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = detail.appointmentTime.difference(now);
    final countdown = diff.isNegative
        ? null
        : diff.inDays > 0
            ? 'In ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}'
            : diff.inHours > 0
                ? 'In ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}'
                : 'Soon';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(detail.appointmentTime),
          style:
              AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          DateFormat('h:mm a').format(detail.appointmentTime),
          style: AppTypography.subtitle.copyWith(color: AppColors.primary),
        ),
        if (countdown != null) ...[
          SizedBox(height: 4.h),
          Text(countdown,
              style: AppTypography.caption
                  .copyWith(color: AppColors.success)),
        ],
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.detail});
  final AppointmentDetail detail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.queueStatus,
        pathParameters: {'appointmentId': detail.id},
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline_rounded,
                color: AppColors.info, size: 24.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are #${detail.queueNumber} in queue',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (detail.estimatedWaitMinutes != null)
                    Text(
                      '~${detail.estimatedWaitMinutes} min wait',
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.info, size: 20.r),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.detail,
    required this.cancelling,
    required this.onCancel,
    this.joiningCall = false,
    this.onJoinCall,
  });

  final AppointmentDetail detail;
  final bool cancelling;
  final VoidCallback onCancel;
  final bool joiningCall;
  final VoidCallback? onJoinCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (detail.canCancel)
          OutlinedButton(
            onPressed: cancelling ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              side: BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: cancelling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Cancel Appointment',
                    style: AppTypography.body
                        .copyWith(color: AppColors.danger),
                  ),
          ),
        if (detail.status == AppointmentStatus.completed) ...[
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: Text(
              'Leave a Review',
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
          ),
        ],
        if (detail.type == AppointmentType.video &&
            detail.isToday &&
            detail.isUpcoming) ...[
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: joiningCall ? null : onJoinCall,
            icon: joiningCall
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.videocam_outlined, color: Colors.white),
            label: Text(
              joiningCall ? 'Connecting...' : 'Join Video Call',
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            AppShimmer.box(width: double.infinity, height: 52.h, radius: 8),
            SizedBox(height: 12.h),
            AppShimmer.box(width: double.infinity, height: 80.h, radius: 12),
            SizedBox(height: 12.h),
            AppShimmer.box(width: double.infinity, height: 80.h, radius: 12),
            SizedBox(height: 12.h),
            AppShimmer.box(width: double.infinity, height: 80.h, radius: 12),
          ],
        ),
      ),
    );
  }
}
