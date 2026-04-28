import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Center;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/center.dart';

class CenterCard extends StatelessWidget {
  const CenterCard({
    super.key,
    required this.center,
    required this.onTap,
    this.onFavoriteToggle,
  });

  final Center center;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CenterImage(
              imageUrl: center.imageUrl,
              isFavorite: center.isFavorite,
              typeBadge: center.typeLabel,
              onFavoriteToggle: onFavoriteToggle,
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          center.name,
                          style: AppTypography.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 14.r, color: AppColors.warning),
                      SizedBox(width: 2.w),
                      Text(
                        center.rating.toStringAsFixed(1),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${center.reviewCount})',
                        style: AppTypography.caption,
                      ),
                      const Spacer(),
                      Icon(Icons.location_on_outlined,
                          size: 12.r, color: AppColors.neutral500),
                      SizedBox(width: 2.w),
                      Text(center.formattedDistance,
                          style: AppTypography.caption),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: center.isOpenNow
                              ? AppColors.success
                              : AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        center.openStatus,
                        style: AppTypography.caption.copyWith(
                          color: center.isOpenNow
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  if (center.specializations.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _SpecializationChips(
                        specializations: center.specializations),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterImage extends StatelessWidget {
  const _CenterImage({
    required this.imageUrl,
    required this.isFavorite,
    required this.typeBadge,
    this.onFavoriteToggle,
  });

  final String? imageUrl;
  final bool isFavorite;
  final String typeBadge;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      child: Stack(
        children: [
          SizedBox(
            height: 140.h,
            width: double.infinity,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.neutral100,
                      child: const Align(
                        child: Icon(Icons.local_hospital_outlined,
                            color: AppColors.neutral300),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.neutral100,
                      child: const Align(
                        child: Icon(Icons.local_hospital_outlined,
                            color: AppColors.neutral300),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.neutral100,
                    child: Align(
                      child: Icon(Icons.local_hospital_outlined,
                          color: AppColors.neutral300, size: 40.r),
                    ),
                  ),
          ),
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                typeBadge,
                style: AppTypography.overline
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
          if (onFavoriteToggle != null)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16.r,
                    color: isFavorite
                        ? AppColors.danger
                        : AppColors.neutral500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecializationChips extends StatelessWidget {
  const _SpecializationChips({required this.specializations});
  final List<String> specializations;

  @override
  Widget build(BuildContext context) {
    final display = specializations.take(3).toList();
    final more = specializations.length - display.length;
    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      children: [
        ...display.map((s) => _Chip(label: s)),
        if (more > 0) _Chip(label: '+$more', isMore: true),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.isMore = false});
  final String label;
  final bool isMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isMore
            ? AppColors.neutral100
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          color: isMore ? AppColors.neutral500 : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
