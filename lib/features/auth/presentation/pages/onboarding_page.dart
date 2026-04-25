import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/storage/preferences_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    (
      icon: Icons.calendar_month_rounded,
      title: 'Book appointments anytime',
      subtitle:
          'Schedule visits with top doctors at your convenience — 24/7, from anywhere.',
      color: AppColors.primary,
    ),
    (
      icon: Icons.psychology_rounded,
      title: 'AI-powered health predictions',
      subtitle:
          'Get personalised insights and early warnings powered by advanced health AI.',
      color: AppColors.info,
    ),
    (
      icon: Icons.videocam_rounded,
      title: 'See doctors from home',
      subtitle:
          'High-quality video consultations so you never have to leave the comfort of home.',
      color: AppColors.accent,
    ),
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    await sl<PreferencesStorage>().setOnboardingCompleted(true);
    if (mounted) context.goNamed(RouteNames.phoneEntry);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, right: 16.w),
                child: TextButton(
                  onPressed: _complete,
                  child: Text(
                    'Skip',
                    style: AppTypography.subtitle
                        .copyWith(color: AppColors.neutral500),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return OnboardingSlide(
                    icon: s.icon,
                    title: s.title,
                    subtitle: s.subtitle,
                    color: s.color,
                  );
                },
              ),
            ),
            _PageIndicator(count: _slides.length, current: _currentPage),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: PrimaryButton(
                label: _currentPage == _slides.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _onNext,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.neutral300,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
