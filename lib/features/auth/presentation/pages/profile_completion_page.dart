import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedDob;
  String _gender = 'Male';

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
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

  void _onComplete() {
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
            phoneNumber: widget.phoneNumber,
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
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.goNamed(RouteNames.home);
        } else if (state is RegisterFailure) {
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
          title: const Text('Complete your profile'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Text(
                    'Tell us about yourself',
                    style: AppTypography.headline,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This helps us personalise your experience.',
                    style: AppTypography.body,
                  ),
                  SizedBox(height: 32.h),
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
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        label: 'Date of Birth',
                        hint: 'Select date',
                        controller: TextEditingController(
                          text: _selectedDob != null
                              ? DateFormat('MMM d, yyyy').format(_selectedDob!)
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
                        .map((g) => ButtonSegment(value: g, label: Text(g)))
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
                  SizedBox(height: 40.h),
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      final isLoading = state is RegisterLoading;
                      return PrimaryButton(
                        label: 'Complete Profile',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onComplete,
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
