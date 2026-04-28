import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_bloc.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_event.dart';
import '../../domain/entities/center_detail.dart';
import '../../domain/usecases/get_center_detail_usecase.dart';

class CenterDetailPage extends StatefulWidget {
  const CenterDetailPage({super.key, required this.centerId});
  final String centerId;

  @override
  State<CenterDetailPage> createState() => _CenterDetailPageState();
}

class _CenterDetailPageState extends State<CenterDetailPage> {
  CenterDetail? _detail;
  String? _error;
  bool _loading = true;
  bool _hoursExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await sl<GetCenterDetailUsecase>()(widget.centerId);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _CenterDetailShimmer();
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

    final detail = _detail!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.h,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: detail.imageUrl != null
                  ? Image.network(detail.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.neutral100,
                      child: const Center(
                        child: Icon(Icons.local_hospital_outlined,
                            color: AppColors.neutral300, size: 64),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detail.name, style: AppTypography.title),
                            SizedBox(height: 4.h),
                            _TypeBadge(detail.typeLabel),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.warning, size: 18),
                              SizedBox(width: 2.w),
                              Text(detail.rating.toStringAsFixed(1),
                                  style: AppTypography.subtitle),
                            ],
                          ),
                          Text('${detail.reviewCount} reviews',
                              style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: '${detail.address}, ${detail.city}',
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () =>
                        launchUrl(Uri(scheme: 'tel', path: detail.phone)),
                    child: _InfoRow(
                      icon: Icons.phone_outlined,
                      text: detail.phone,
                      isLink: true,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: detail.isOpenNow
                              ? AppColors.success
                              : AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        detail.openStatus,
                        style: AppTypography.body.copyWith(
                          color: detail.isOpenNow
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (detail.workingHours.isNotEmpty) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(
                              () => _hoursExpanded = !_hoursExpanded),
                          child: Text(
                            _hoursExpanded ? 'Hide hours' : 'See hours',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_hoursExpanded && detail.workingHours.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border:
                              Border.all(color: AppColors.neutral300),
                        ),
                        child: Column(
                          children: detail.workingHours
                              .map((h) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 3.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(h.day,
                                            style: AppTypography.caption),
                                        Text(
                                          h.displayHours,
                                          style:
                                              AppTypography.caption.copyWith(
                                            color: h.isOpen
                                                ? AppColors.neutral700
                                                : AppColors.danger,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  if (detail.about != null) ...[
                    SizedBox(height: 20.h),
                    Text('About', style: AppTypography.subtitle),
                    SizedBox(height: 8.h),
                    Text(detail.about!, style: AppTypography.body),
                  ],
                  if (detail.services.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Text('Services', style: AppTypography.subtitle),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: detail.services
                          .map((s) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.full),
                                ),
                                child: Text(s, style: AppTypography.caption),
                              ))
                          .toList(),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Text('Our Doctors', style: AppTypography.subtitle),
                  SizedBox(height: 12.h),
                  Text(
                    'Tap a doctor to view their profile and check availability.',
                    style: AppTypography.caption,
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<BookingFlowBloc>()
                  .add(CenterSelected(detail));
              context.push('/book/doctors/${detail.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(
              'Book Appointment',
              style:
                  AppTypography.subtitle.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.isLink = false,
  });
  final IconData icon;
  final String text;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: AppColors.neutral500),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              color: isLink ? AppColors.primary : AppColors.neutral700,
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _CenterDetailShimmer extends StatelessWidget {
  const _CenterDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppShimmer.box(width: double.infinity, height: 220.h, radius: 0),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.line(width: 200.w, height: 24),
                  SizedBox(height: 8.h),
                  AppShimmer.line(width: 100.w),
                  SizedBox(height: 16.h),
                  AppShimmer.line(width: double.infinity),
                  SizedBox(height: 8.h),
                  AppShimmer.line(width: 150.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
