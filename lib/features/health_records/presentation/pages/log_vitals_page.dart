import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/vitals/vitals_bloc.dart';
import '../bloc/vitals/vitals_event.dart';
import '../bloc/vitals_form/vitals_form_bloc.dart';
import '../bloc/vitals_form/vitals_form_event.dart';
import '../bloc/vitals_form/vitals_form_state.dart';

class LogVitalsPage extends StatefulWidget {
  const LogVitalsPage({super.key, this.recordId});
  final String? recordId;

  @override
  State<LogVitalsPage> createState() => _LogVitalsPageState();
}

class _LogVitalsPageState extends State<LogVitalsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VitalsFormBloc, VitalsFormState>(
      listener: (context, state) {
        if (state.status == VitalsFormStatus.success) {
          context.read<VitalsBloc>().add(const VitalsRefreshed());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vitals saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state.status == VitalsFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.recordId != null ? 'Edit Vitals' : 'Log Vitals',
            style: AppTypography.title,
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: BlocBuilder<VitalsFormBloc, VitalsFormState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('Blood Pressure'),
                    Row(
                      children: [
                        Expanded(
                          child: _VitalField(
                            label: 'Systolic',
                            hint: '120',
                            unit: 'mmHg',
                            field: 'systolic',
                            errorText: state.errors['systolic'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'systolic', value: v)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _VitalField(
                            label: 'Diastolic',
                            hint: '80',
                            unit: 'mmHg',
                            field: 'diastolic',
                            errorText: state.errors['diastolic'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'diastolic', value: v)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _SectionHeader('Glucose'),
                    _VitalField(
                      label: 'Blood Glucose',
                      hint: '100',
                      unit: 'mg/dL',
                      field: 'glucose',
                      errorText: state.errors['glucose'],
                      onChanged: (v) => context
                          .read<VitalsFormBloc>()
                          .add(VitalsFormFieldChanged(
                              field: 'glucose', value: v)),
                    ),
                    SizedBox(height: 16.h),
                    _SectionHeader('Body Measurements'),
                    Row(
                      children: [
                        Expanded(
                          child: _VitalField(
                            label: 'Weight',
                            hint: '70',
                            unit: 'kg',
                            field: 'weight',
                            errorText: state.errors['weight'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'weight', value: v)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _VitalField(
                            label: 'Height',
                            hint: '170',
                            unit: 'cm',
                            field: 'height',
                            errorText: state.errors['height'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'height', value: v)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _SectionHeader('Cardiovascular & Respiratory'),
                    Row(
                      children: [
                        Expanded(
                          child: _VitalField(
                            label: 'Heart Rate',
                            hint: '72',
                            unit: 'bpm',
                            field: 'heartRate',
                            errorText: state.errors['heartRate'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'heartRate', value: v)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _VitalField(
                            label: 'Resp. Rate',
                            hint: '16',
                            unit: '/min',
                            field: 'respiratoryRate',
                            errorText: state.errors['respiratoryRate'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'respiratoryRate', value: v)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _SectionHeader('Other'),
                    Row(
                      children: [
                        Expanded(
                          child: _VitalField(
                            label: 'Temperature',
                            hint: '37.0',
                            unit: '°C',
                            field: 'temperature',
                            errorText: state.errors['temperature'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'temperature', value: v)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _VitalField(
                            label: 'SpO₂',
                            hint: '98',
                            unit: '%',
                            field: 'oxygenSaturation',
                            errorText: state.errors['oxygenSaturation'],
                            onChanged: (v) => context
                                .read<VitalsFormBloc>()
                                .add(VitalsFormFieldChanged(
                                    field: 'oxygenSaturation', value: v)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Any additional observations...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: AppColors.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                      onChanged: (v) => context
                          .read<VitalsFormBloc>()
                          .add(VitalsFormFieldChanged(
                              field: 'notes', value: v)),
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: state.status == VitalsFormStatus.loading
                          ? null
                          : () => context
                              .read<VitalsFormBloc>()
                              .add(VitalsFormSubmitted(
                                  recordId: widget.recordId)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: state.status == VitalsFormStatus.loading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Vitals'),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.neutral700,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _VitalField extends StatelessWidget {
  const _VitalField({
    required this.label,
    required this.hint,
    required this.unit,
    required this.field,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String hint;
  final String unit;
  final String field;
  final String? errorText;
  final ValueChanged<String> onChanged;

  Color get _borderColor =>
      errorText != null ? AppColors.danger : AppColors.neutral300;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              suffixText: unit,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                    color: errorText != null
                        ? AppColors.danger
                        : AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.white,
              errorText: errorText,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
