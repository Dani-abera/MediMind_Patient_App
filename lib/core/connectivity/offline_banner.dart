import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'connectivity_cubit.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: status == ConnectivityStatus.disconnected ? 36.h : 0,
              color: AppColors.warning,
              child: status == ConnectivityStatus.disconnected
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 16.sp, color: AppColors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'No internet connection. Some features unavailable.',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    )
                  : null,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
