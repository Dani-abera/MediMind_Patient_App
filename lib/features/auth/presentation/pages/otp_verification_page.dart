import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/otp/otp_bloc.dart';
import '../bloc/otp/otp_event.dart';
import '../bloc/otp/otp_state.dart';
import '../widgets/otp_timer_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onCompleted(String code) {
    if (code.length != 6) return;

    _pinFocus.unfocus();
    HapticFeedback.lightImpact();

    context.read<OtpBloc>().add(
      OtpSubmitted(phoneNumber: widget.phoneNumber, otpCode: code),
    );
  }

  String _maskedPhone(String phone) {
    if (phone.length <= 4) return phone;
    final suffix = phone.substring(phone.length - 4);
    if (phone.length < 8) {
      return '*** $suffix';
    }

    final prefix = phone.substring(0, phone.length - 7);
    return '$prefix XXX $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: AppTypography.title.copyWith(color: AppColors.neutral900),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral300),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          final user = state.user;

          context.read<AuthBloc>().add(UserLoggedIn(user));

          if (user.isProfileComplete) {
            context.goNamed(RouteNames.home);
          } else {
            context.goNamed(RouteNames.profileCompletion);
          }
        } else if (state is OtpFailure) {
          _shakeController
            ..stop()
            ..forward(from: 0);
          _pinController.clear();
          _pinFocus.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(RouteNames.phoneEntry);
                }
              },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                Text('Verify your phone', style: AppTypography.headline),
                SizedBox(height: 8.h),
                Text(
                  'We sent a 6-digit code to ${_maskedPhone(widget.phoneNumber)}',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                BlocBuilder<OtpBloc, OtpState>(
                  builder: (context, state) {
                    final isVerifying = state is OtpVerifying;
                    return AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(_shakeAnim.value, 0),
                        child: child,
                      ),
                      child: Pinput(
                        controller: _pinController,
                        focusNode: _pinFocus,
                        length: 6,
                        autofocus: true,
                        enabled: !isVerifying,
                        onCompleted: _onCompleted,
                        defaultPinTheme: defaultTheme,
                        focusedPinTheme: defaultTheme.copyWith(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        errorPinTheme: defaultTheme.copyWith(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.danger),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32.h),
                BlocBuilder<OtpBloc, OtpState>(
                  builder: (context, state) {
                    int remaining = 0;
                    if (state is OtpSent) remaining = state.remainingSeconds;
                    if (state is OtpFailure) remaining = state.remainingSeconds;
                    if (state is OtpVerifying) {
                      remaining = state.remainingSeconds;
                    }

                    final canResend = state is OtpExpired;

                    return OtpTimerWidget(
                      remainingSeconds: remaining,
                      canResend: canResend,
                      onResend: () => context.read<OtpBloc>().add(
                        OtpResendRequested(widget.phoneNumber),
                      ),
                    );
                  },
                ),
                const Spacer(),
                BlocBuilder<OtpBloc, OtpState>(
                  builder: (context, state) {
                    if (state is OtpVerifying) {
                      return const CircularProgressIndicator();
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
