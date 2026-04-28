import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_bloc.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_event.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctor_detail_usecase.dart';

class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({super.key, required this.doctorId});
  final String doctorId;

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  Doctor? _doctor;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<GetDoctorDetailUsecase>()(widget.doctorId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (d) => setState(() {
        _doctor = d;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _DoctorDetailShimmer();
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
                  child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final d = _doctor!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(doctor: d),
            SizedBox(height: 16.h),
            _StatsRow(doctor: d),
            SizedBox(height: 20.h),
            if (d.bio != null) ...[
              _Section(title: 'About', child: Text(d.bio!, style: AppTypography.body)),
              SizedBox(height: 20.h),
            ],
            if (d.qualifications.isNotEmpty)
              _Section(
                title: 'Qualifications',
                child: Column(
                  children: d.qualifications
                      .map((q) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            child: Row(
                              children: [
                                const Icon(Icons.school_outlined,
                                    size: 14, color: AppColors.primary),
                                SizedBox(width: 8.w),
                                Expanded(
                                    child: Text(q, style: AppTypography.body)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            if (d.languages.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _Section(
                title: 'Languages',
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: d.languages
                      .map((l) => _Chip(l))
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: 20.h),
            _Section(
              title: 'Consultation Fee',
              child: Text(
                d.formattedFee,
                style: AppTypography.title
                    .copyWith(color: AppColors.primary),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<BookingFlowBloc>()
                  .add(DoctorSelected(d));
              context.pushNamed(RouteNames.appointmentSlots);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(
              'Check Availability',
              style:
                  AppTypography.subtitle.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final initials = doctor.fullName.isNotEmpty
        ? doctor.fullName.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36.r,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: doctor.avatarUrl != null
                ? NetworkImage(doctor.avatarUrl!)
                : null,
            child: doctor.avatarUrl == null
                ? Text(initials,
                    style: AppTypography.title
                        .copyWith(color: AppColors.white))
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. ${doctor.fullName}', style: AppTypography.subtitle),
                Text(doctor.specialization,
                    style: AppTypography.body
                        .copyWith(color: AppColors.primary)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 16),
                    SizedBox(width: 2.w),
                    Text(doctor.rating.toStringAsFixed(1),
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(' (${doctor.reviewCount} reviews)',
                        style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _Stat(label: 'Experience', value: '${doctor.yearsExperience} yrs'),
          _Stat(label: 'Patients', value: '${doctor.patientsSeen}+'),
          _Stat(label: 'Rating', value: doctor.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.subtitle
                    .copyWith(color: AppColors.primary)),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}

class _DoctorDetailShimmer extends StatelessWidget {
  const _DoctorDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            AppShimmer.box(width: double.infinity, height: 100.h, radius: 12),
            SizedBox(height: 16.h),
            AppShimmer.box(width: double.infinity, height: 80.h, radius: 12),
            SizedBox(height: 16.h),
            AppShimmer.line(width: double.infinity),
            SizedBox(height: 8.h),
            AppShimmer.line(width: 200.w),
          ],
        ),
      ),
    );
  }
}
