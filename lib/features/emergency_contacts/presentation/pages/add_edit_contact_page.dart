import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/emergency_contact.dart';
import '../bloc/emergency_contacts_bloc.dart';
import '../bloc/emergency_contacts_event.dart';
import '../bloc/emergency_contacts_state.dart';

class AddEditContactPage extends StatefulWidget {
  const AddEditContactPage({super.key, this.contact});
  final EmergencyContact? contact;

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String _relationship = 'Spouse';
  bool _isPrimary = false;

  static const _relationships = [
    'Spouse', 'Parent', 'Sibling', 'Child', 'Friend', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameCtrl = TextEditingController(text: c?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: c?.phoneNumber ?? '');
    if (c != null) {
      _relationship = c.relationship;
      _isPrimary = c.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<EmergencyContactsBloc>();
    if (widget.contact == null) {
      bloc.add(EmergencyContactAdded(
        fullName: _nameCtrl.text.trim(),
        relationship: _relationship,
        phoneNumber: _phoneCtrl.text.trim(),
        isPrimary: _isPrimary,
      ));
    } else {
      bloc.add(EmergencyContactUpdated(widget.contact!.copyWith(
        fullName: _nameCtrl.text.trim(),
        relationship: _relationship,
        phoneNumber: _phoneCtrl.text.trim(),
        isPrimary: _isPrimary,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contact != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Contact' : 'Add Contact',
            style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: BlocListener<EmergencyContactsBloc, EmergencyContactsState>(
        listener: (context, state) {
          if (state is EmergencyContactsActionSuccess) {
            Navigator.pop(context);
          }
          if (state is EmergencyContactsFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                _Field(
                  label: 'Phone Number',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                Text('Relationship', style: AppTypography.body),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: _relationship,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  items: _relationships
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _relationship = v!),
                ),
                SizedBox(height: 16.h),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Set as primary contact',
                      style: AppTypography.body),
                  value: _isPrimary,
                  onChanged: (v) => setState(() => _isPrimary = v),
                  activeThumbColor: AppColors.primary,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(isEdit ? 'Save Changes' : 'Add Contact',
                        style: AppTypography.subtitle
                            .copyWith(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
