import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer._({required this.child});

  factory AppShimmer.box({
    required double width,
    required double height,
    double? radius,
  }) => AppShimmer._(
        child: _ShimmerBox(width: width, height: height, radius: radius),
      );

  factory AppShimmer.circle({required double size}) => AppShimmer._(
        child: _ShimmerBox(
          width: size,
          height: size,
          radius: size / 2,
        ),
      );

  factory AppShimmer.line({required double width, double height = 14}) =>
      AppShimmer._(
        child: _ShimmerBox(width: width, height: height, radius: 4),
      );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral300,
      highlightColor: AppColors.neutral100,
      child: child,
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: radius != null ? BorderRadius.circular(radius!) : null,
      ),
    );
  }
}
