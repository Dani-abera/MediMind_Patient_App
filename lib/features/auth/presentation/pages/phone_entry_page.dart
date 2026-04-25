import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../bloc/otp/otp_bloc.dart';
import '../bloc/otp/otp_event.dart';
import '../bloc/otp/otp_state.dart';
import '../widgets/phone_input_field.dart';
import 'register_bottom_sheet.dart';

class PhoneEntryPage extends StatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  State<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber =>
      '+251${_phoneController.text.trim().replaceAll(RegExp(r'\D'), '')}';

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<OtpBloc>().add(OtpRequested(_fullPhoneNumber));
    }
  }

  void _showRegisterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<OtpBloc>(),
        child: const RegisterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpSent) {
          context.goNamed(
            RouteNames.otpVerification,
            extra: state.phoneNumber,
          );
        } else if (state is OtpFailure && state.remainingSeconds == 0) {
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
          title: const Text('Sign In'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Text(
                    'Enter your phone number',
                    style: AppTypography.headline,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "We'll send you a verification code",
                    style: AppTypography.body,
                  ),
                  SizedBox(height: 32.h),
                  PhoneInputField(controller: _phoneController),
                  SizedBox(height: 12.h),
                  Center(
                    child: TextButton(
                      onPressed: _showRegisterSheet,
                      child: Text(
                        "Don't have an account? Create account",
                        style: AppTypography.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<OtpBloc, OtpState>(
                    builder: (context, state) {
                      final isLoading = state is OtpSending;
                      return PrimaryButton(
                        label: 'Continue',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onContinue,
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
