import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/storage/preferences_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  DateTime? _selectedDob;
  String _gender = 'Male';

  // Tracks whether the user tapped Continue — prevents the initial
  // ProfileLoaded (from ProfileRequested) from triggering navigation.
  bool _submitted = false;

  static const _genders = ['Male', 'Female', 'Not Mentioned'];

  @override
  void initState() {
    super.initState();

    // Pre-fill from the cached AuthBloc user.
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      _nameController.text = user.fullName;
      _selectedDob = user.dateOfBirth;
      _gender = user.gender ?? 'Male';
    }

    // Load the profile so ProfileBloc has a current user — required by
    // _onUpdated, which checks currentUser != null before patching.
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? now.subtract(const Duration(days: 365 * 25)),
      firstDate: now.subtract(const Duration(days: 365 * 120)),
      lastDate: now.subtract(const Duration(days: 365 * 18)),
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
    setState(() => _submitted = true);
    context.read<ProfileBloc>().add(ProfileUpdated(
          fullName: _nameController.text.trim(),
          dateOfBirth: _selectedDob,
          gender: _gender,
        ));
  }

  Future<void> _markCompleteAndNavigate() async {
    final authState = context.read<AuthBloc>().state;
    final prefs = sl<PreferencesStorage>();
    String userId = '';

    if (authState is Authenticated) {
      userId = authState.user.patientId;
      await prefs.setProfileSetupComplete(userId);
    }

    if (!mounted) return;

    // If health data was already filled in a previous session, skip that gate.
    if (prefs.isHealthSetupComplete(userId)) {
      context.goNamed(RouteNames.home);
    } else {
      context.goNamed(RouteNames.healthSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (_submitted && state is ProfileSaved) {
          setState(() => _submitted = false);
          // Sync the updated user (with the real fullName) into AuthBloc so
          // the greeting on home page shows the correct name, not "Patient".
          context.read<AuthBloc>().add(UserLoggedIn(state.user));
          sl<AuthRepository>().refreshCachedUser(state.user);
          _markCompleteAndNavigate();
        } else if (state is ProfileFailure) {
          setState(() => _submitted = false);
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
          automaticallyImplyLeading: false,
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
                  Text('Tell us about yourself', style: AppTypography.headline),
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
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
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
                  SizedBox(height: 40.h),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isLoading = state is ProfileSaving ||
                          (state is ProfileLoading && !_submitted);
                      return PrimaryButton(
                        label: 'Continue',
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
