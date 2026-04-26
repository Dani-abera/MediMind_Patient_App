import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/healthcare_center.dart';

class NearbyCentersSection extends StatelessWidget {
  const NearbyCentersSection({super.key, required this.centers});

  final List<HealthcareCenter> centers;

  @override
  Widget build(BuildContext context) {
    if (centers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text('Nearby Centers', style: AppTypography.subtitle),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: centers.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) =>
                _CenterCard(center: centers[i]),
          ),
        ),
      ],
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center});
  final HealthcareCenter center;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/book/center/${center.id}'),
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 72.h,
                width: double.infinity,
                color: AppColors.neutral100,
                child: center.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: center.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _CenterPlaceholder(),
                      )
                    : const _CenterPlaceholder(),
              ),
              Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10.r,
                          color: AppColors.neutral500,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          center.formattedDistance,
                          style: AppTypography.overline,
                        ),
                      ],
                    ),
                    if (center.specializations.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          center.specializations.first,
                          style: AppTypography.overline.copyWith(
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterPlaceholder extends StatelessWidget {
  const _CenterPlaceholder();
  @override
  Widget build(BuildContext context) => Center(
        child: Icon(
          Icons.local_hospital_outlined,
          color: AppColors.neutral300,
          size: 28.r,
        ),
      );
}
