import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    (icon: FontAwesomeIcons.house, label: 'Home'),
    (icon: FontAwesomeIcons.calendarCheck, label: 'Book'),
    (icon: FontAwesomeIcons.heartPulse, label: 'Health'),
    (icon: FontAwesomeIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 68.h + bottomPad,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral300),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final selected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabSelected(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.h,
                    width: selected ? 32.w : 0,
                    margin: EdgeInsets.only(bottom: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
                      ),
                    ),
                  ),
                  FaIcon(
                    tab.icon,
                    size: 20.r,
                    color: selected
                        ? AppColors.primary
                        : AppColors.neutral500,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tab.label,
                    style: AppTypography.overline.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.neutral500,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: bottomPad / 2),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
