import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../di/service_locator.dart';
import '../../storage/preferences_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CoachMarkStep {
  const CoachMarkStep({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.alignment,
  });

  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final Alignment alignment;
}

const _steps = [
  CoachMarkStep(
    titleKey: 'onboarding.step1Title',
    bodyKey: 'onboarding.step1Body',
    icon: Icons.grid_view_rounded,
    alignment: Alignment.bottomCenter,
  ),
  CoachMarkStep(
    titleKey: 'onboarding.step2Title',
    bodyKey: 'onboarding.step2Body',
    icon: Icons.notifications_outlined,
    alignment: Alignment.topRight,
  ),
  CoachMarkStep(
    titleKey: 'onboarding.step3Title',
    bodyKey: 'onboarding.step3Body',
    icon: Icons.psychology_outlined,
    alignment: Alignment.center,
  ),
  CoachMarkStep(
    titleKey: 'onboarding.step4Title',
    bodyKey: 'onboarding.step4Body',
    icon: Icons.person_outline_rounded,
    alignment: Alignment.bottomRight,
  ),
];

class CoachMarkOverlay extends StatefulWidget {
  const CoachMarkOverlay({super.key, required this.child, required this.show});

  final Widget child;
  final bool show;

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _visible = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.show) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _visible = true);
        _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step < _steps.length - 1) {
      await _ctrl.reverse();
      setState(() => _step++);
      _ctrl.forward();
    } else {
      await _dismiss();
    }
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    setState(() => _visible = false);
    await sl<PreferencesStorage>().setTutorialCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    final step = _steps[_step];
    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: _next,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: SafeArea(
                child: Align(
                  alignment: step.alignment,
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: _CoachCard(
                      step: _step,
                      total: _steps.length,
                      coachStep: step,
                      onNext: _next,
                      onSkip: _dismiss,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.step,
    required this.total,
    required this.coachStep,
    required this.onNext,
    required this.onSkip,
  });

  final int step;
  final int total;
  final CoachMarkStep coachStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    coachStep.icon,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${step + 1} / $total',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'common.skip'.tr(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              coachStep.titleKey.tr(),
              style: AppTypography.title.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              coachStep.bodyKey.tr(),
              style: AppTypography.body.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            SizedBox(height: 20.h),
            _StepIndicator(current: step, total: total),
            SizedBox(height: 16.h),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      child: Text('onboarding.previous'.tr()),
                    ),
                  ),
                if (step > 0) SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: onNext,
                    child: Text(
                      isLast
                          ? 'onboarding.getStarted'.tr()
                          : 'common.next'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(right: 6.w),
          width: i == current ? 20.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.neutral300,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
