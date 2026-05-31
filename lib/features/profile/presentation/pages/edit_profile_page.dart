import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  DateTime? _dateOfBirth;
  String? _gender;

  static const _genders = ['Male', 'Female', 'Not Mentioned'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _populateFrom(dynamic user) {
    _nameCtrl.text = user.fullName;
    _emailCtrl.text = user.email ?? '';
    _dateOfBirth = user.dateOfBirth;
    _gender = user.gender;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      context
          .read<ProfileBloc>()
          .add(ProfileImageUploaded(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(ProfileUpdated(
          fullName: _nameCtrl.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isSetupMode = _dateOfBirth == null &&
                (_gender == null || _gender!.isEmpty);
            return Text(
              isSetupMode ? 'Set up your profile' : 'Edit Profile',
              style: AppTypography.title,
            );
          },
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            setState(() => _populateFrom(state.user));
          }
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileSaving;
          final user = state is ProfileLoaded
              ? state.user
              : (state is ProfileSaving
                  ? state.user
                  : (state is ProfileSaved ? state.user : null));

          if (user == null && state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // "Setup mode": profile has only default values (no DOB or gender set).
          final isSetupMode =
              _dateOfBirth == null && (_gender == null || _gender!.isEmpty);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _AvatarPicker(
                        imageUrl: user?.profileImageUrl,
                        onTap: _pickImage,
                        onDelete: user?.profileImageUrl != null
                            ? () => context
                                .read<ProfileBloc>()
                                .add(const ProfileImageDeleted())
                            : null,
                      ),
                      SizedBox(height: 24.h),
                      _Field(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      _Field(
                        label: 'Email (optional)',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),
                      _DateField(
                        label: 'Date of Birth',
                        value: _dateOfBirth,
                        onTap: _pickDate,
                      ),
                      SizedBox(height: 16.h),
                      _GenderSelector(
                        genders: _genders,
                        selected: _gender,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                                EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.r)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white))
                              : Text(
                                  isSetupMode ? 'Get Started' : 'Save Changes',
                                  style: AppTypography.subtitle.copyWith(
                                      color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker(
      {required this.imageUrl,
      required this.onTap,
      required this.onDelete});
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 48.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Icon(Icons.person, size: 48.sp, color: AppColors.primary)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.white, width: 2),
              ),
              child: Icon(Icons.camera_alt,
                  size: 14.sp, color: AppColors.white),
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.white, width: 2),
                ),
                child:
                    Icon(Icons.close, size: 12.sp, color: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r)),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.day}/${value!.month}/${value!.year}'
                        : 'Select date',
                    style: value != null
                        ? AppTypography.body
                        : AppTypography.body.copyWith(
                            color: AppColors.neutral500),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 18.sp, color: AppColors.neutral500),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.genders,
    required this.selected,
    required this.onChanged,
  });
  final List<String> genders;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTypography.body),
        SizedBox(height: 8.h),
        SegmentedButton<String>(
          segments: genders
              .map((g) => ButtonSegment(value: g, label: Text(g)))
              .toList(),
          selected: selected != null ? {selected!} : {},
          emptySelectionAllowed: true,
          onSelectionChanged: (s) =>
              onChanged(s.isEmpty ? null : s.first),
        ),
      ],
    );
  }
}
