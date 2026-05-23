import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../bloc/otp/otp_bloc.dart';
import '../bloc/otp/otp_event.dart';
import '../bloc/otp/otp_state.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';
import '../widgets/phone_input_field.dart';

/// Bottom sheet for new patient registration.
/// Caller MUST provide OtpBloc in context (PhoneEntryPage does this via ShellRoute).
class RegisterBottomSheet extends StatelessWidget {
  const RegisterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => sl<RegisterBloc>(),
      child: const _RegisterSheetContent(),
    );
  }
}

class _RegisterSheetContent extends StatefulWidget {
  const _RegisterSheetContent();

  @override
  State<_RegisterSheetContent> createState() => _RegisterSheetContentState();
}

class _RegisterSheetContentState extends State<_RegisterSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedDob;
  String _gender = 'Male';

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 25)),
      firstDate: now.subtract(const Duration(days: 365 * 120)),
      lastDate: now.subtract(const Duration(days: 365 * 13)),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }
    context.read<RegisterBloc>().add(
          RegisterSubmitted(
            fullName: _nameController.text.trim(),
            phoneNumber:
                '+251${_phoneController.text.trim().replaceAll(RegExp(r'\D'), '')}',
            dateOfBirth: DateFormat('yyyy-MM-dd').format(_selectedDob!),
            gender: _gender,
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              context.read<OtpBloc>().add(OtpRequested(state.phoneNumber));
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
        ),
        BlocListener<OtpBloc, OtpState>(
          listenWhen: (previous, current) =>
              current is OtpSent && previous is! OtpSent,
          listener: (context, state) {
            if (state is OtpSent) {
              Navigator.of(context).pop();
              context.goNamed(
                RouteNames.otpVerification,
                extra: state.phoneNumber,
              );
            }
          },
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Create account', style: AppTypography.headline),
                SizedBox(height: 24.h),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                SizedBox(height: 16.h),
                PhoneInputField(controller: _phoneController),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: AppTextField(
                      label: 'Date of Birth',
                      hint: 'Select date',
                      controller: TextEditingController(
                        text: _selectedDob != null
                            ? DateFormat('MMM d, yyyy')
                                .format(_selectedDob!)
                            : '',
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined),
                      validator: (_) => _selectedDob == null
                          ? 'Date of birth is required'
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Gender', style: AppTypography.subtitle),
                SizedBox(height: 8.h),
                SegmentedButton<String>(
                  segments: _genders
                      .map((g) =>
                          ButtonSegment(value: g, label: Text(g)))
                      .toList(),
                  selected: {_gender},
                  onSelectionChanged: (s) =>
                      setState(() => _gender = s.first),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _emailController,
                  label: 'Email (optional)',
                  hint: 'you@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24.h),
                BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    final isLoading = state is RegisterLoading;
                    return PrimaryButton(
                      label: 'Create Account',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onSubmit,
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
