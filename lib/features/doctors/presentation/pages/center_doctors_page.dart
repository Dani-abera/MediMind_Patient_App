import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_center_doctors_usecase.dart';
import '../widgets/doctor_card.dart';

class CenterDoctorsPage extends StatefulWidget {
  const CenterDoctorsPage({
    super.key,
    required this.centerId,
    required this.centerName,
  });

  final String centerId;
  final String centerName;

  @override
  State<CenterDoctorsPage> createState() => _CenterDoctorsPageState();
}

class _CenterDoctorsPageState extends State<CenterDoctorsPage> {
  List<Doctor> _doctors = [];
  String? _error;
  bool _loading = true;
  String? _selectedSpecialization;
  final List<String> _specializations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<GetCenterDoctorsUsecase>()(
      widget.centerId,
      specialization: _selectedSpecialization,
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (doctors) => setState(() {
        _doctors = doctors;
        _loading = false;
        if (_specializations.isEmpty) {
          final specs = doctors
              .map((d) => d.specialization)
              .toSet()
              .toList()
            ..sort();
          _specializations.addAll(specs);
        }
      }),
    );
  }

  Future<void> _filter(String? specialization) async {
    setState(() {
      _selectedSpecialization = specialization;
      _loading = true;
      _error = null;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.centerName),
        bottom: _specializations.isEmpty
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: SizedBox(
                  height: 48.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: _specializations.length + 1,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        final isAll = _selectedSpecialization == null;
                        return FilterChip(
                          label: const Text('All'),
                          selected: isAll,
                          onSelected: (_) => _filter(null),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.primary,
                        );
                      }
                      final spec = _specializations[i - 1];
                      final isSelected = _selectedSpecialization == spec;
                      return FilterChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (_) =>
                            _filter(isSelected ? null : spec),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
      ),
      body: _build(),
    );
  }

  Widget _build() {
    if (_loading) return const _DoctorsShimmer();

    if (_error != null) {
      return Center(
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
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined,
                size: 48.r, color: AppColors.neutral300),
            SizedBox(height: 12.h),
            Text('No doctors found', style: AppTypography.body),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loading = true;
          _error = null;
        });
        await _load();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: _doctors.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => DoctorCard(
          doctor: _doctors[i],
          onTap: () => context.pushNamed(
            RouteNames.doctorDetail,
            pathParameters: {'id': _doctors[i].id},
            extra: {'centerId': widget.centerId},
          ),
        ),
      ),
    );
  }
}

class _DoctorsShimmer extends StatelessWidget {
  const _DoctorsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AppShimmer.box(
                width: double.infinity, height: 96.h, radius: 12),
          ),
        ),
      ),
    );
  }
}
