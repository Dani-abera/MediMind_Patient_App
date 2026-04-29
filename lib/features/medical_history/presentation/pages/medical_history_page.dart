import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/medical_history.dart';
import '../bloc/medical_history_bloc.dart';
import '../bloc/medical_history_event.dart';
import '../bloc/medical_history_state.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  late MedicalHistory _draft;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _draft = const MedicalHistory();
    context.read<MedicalHistoryBloc>().add(const MedicalHistoryRequested());
  }

  void _update(MedicalHistory updated) {
    setState(() {
      _draft = updated;
      _dirty = true;
    });
  }

  void _save() {
    context
        .read<MedicalHistoryBloc>()
        .add(MedicalHistoryUpdated(_draft));
    setState(() => _dirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medical History', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          if (_dirty)
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: BlocConsumer<MedicalHistoryBloc, MedicalHistoryState>(
        listener: (context, state) {
          if (state is MedicalHistoryLoaded || state is MedicalHistorySaved) {
            final h = state is MedicalHistoryLoaded
                ? state.history
                : (state as MedicalHistorySaved).history;
            setState(() {
              _draft = h;
              _dirty = false;
            });
          }
          if (state is MedicalHistorySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved successfully')),
            );
          }
          if (state is MedicalHistoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicalHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BloodTypeSection(
                      value: _draft.bloodType,
                      onChanged: (v) =>
                          _update(_draft.copyWith(bloodType: v)),
                    ),
                    SizedBox(height: 16.h),
                    _ChipsSection(
                      title: 'Chronic Conditions',
                      items: _draft.chronicConditions,
                      hint: 'Add condition',
                      onChanged: (list) =>
                          _update(_draft.copyWith(chronicConditions: list)),
                    ),
                    SizedBox(height: 16.h),
                    _AllergiesSection(
                      allergies: _draft.allergies,
                      onChanged: (list) =>
                          _update(_draft.copyWith(allergies: list)),
                    ),
                    SizedBox(height: 16.h),
                    _ChipsSection(
                      title: 'Family History',
                      items: _draft.familyHistory,
                      hint: 'Add condition',
                      onChanged: (list) =>
                          _update(_draft.copyWith(familyHistory: list)),
                    ),
                    SizedBox(height: 16.h),
                    _LifestyleSection(
                      isSmoker: _draft.isSmoker,
                      alcoholConsumption: _draft.alcoholConsumption,
                      onSmokerChanged: (v) =>
                          _update(_draft.copyWith(isSmoker: v)),
                      onAlcoholChanged: (v) =>
                          _update(_draft.copyWith(alcoholConsumption: v)),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
              if (state is MedicalHistorySaving)
                Container(
                  color: AppColors.neutral900.withValues(alpha: 0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BloodTypeSection extends StatelessWidget {
  const _BloodTypeSection({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _types = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blood Type', style: AppTypography.title),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: _types.map((t) {
            final selected = value == t;
            return ChoiceChip(
              label: Text(t),
              selected: selected,
              onSelected: (_) => onChanged(selected ? null : t),
              selectedColor: AppColors.primary,
              labelStyle: AppTypography.body.copyWith(
                color: selected ? AppColors.white : AppColors.neutral700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ChipsSection extends StatelessWidget {
  const _ChipsSection({
    required this.title,
    required this.items,
    required this.hint,
    required this.onChanged,
  });
  final String title;
  final List<String> items;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  void _add(BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add $title item'),
        content: TextField(
            controller: ctrl,
            decoration: InputDecoration(hintText: hint),
            autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onChanged([...items, result]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTypography.title),
            const Spacer(),
            IconButton(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
        if (items.isEmpty)
          Text('None added', style: AppTypography.caption)
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: items
                .map((item) => Chip(
                      label: Text(item, style: AppTypography.caption),
                      onDeleted: () =>
                          onChanged(items.where((e) => e != item).toList()),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _AllergiesSection extends StatelessWidget {
  const _AllergiesSection(
      {required this.allergies, required this.onChanged});
  final List<Allergy> allergies;
  final ValueChanged<List<Allergy>> onChanged;

  void _add(BuildContext context) async {
    final allergenCtrl = TextEditingController();
    var severity = AllergenSeverity.mild;
    final result = await showDialog<Allergy>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add Allergy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: allergenCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Allergen name')),
              SizedBox(height: 12.h),
              DropdownButtonFormField<AllergenSeverity>(
                initialValue: severity,
                items: AllergenSeverity.values
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name[0].toUpperCase() +
                            s.name.substring(1))))
                    .toList(),
                onChanged: (v) => setSt(() => severity = v!),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (allergenCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(
                        ctx,
                        Allergy(
                            allergen: allergenCtrl.text.trim(),
                            severity: severity));
                  }
                },
                child: const Text('Add')),
          ],
        ),
      ),
    );
    if (result != null) onChanged([...allergies, result]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Allergies', style: AppTypography.title),
            const Spacer(),
            IconButton(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
        if (allergies.isEmpty)
          Text('None added', style: AppTypography.caption)
        else
          ...allergies.map((a) {
            final severityColor = switch (a.severity) {
              AllergenSeverity.mild => AppColors.success,
              AllergenSeverity.moderate => AppColors.warning,
              AllergenSeverity.severe => AppColors.danger,
            };
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(a.allergen, style: AppTypography.body),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(a.severity.name,
                        style: AppTypography.caption
                            .copyWith(color: severityColor)),
                  ),
                  IconButton(
                      onPressed: () => onChanged(
                          allergies.where((x) => x != a).toList()),
                      icon: const Icon(Icons.close, size: 16)),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _LifestyleSection extends StatelessWidget {
  const _LifestyleSection({
    required this.isSmoker,
    required this.alcoholConsumption,
    required this.onSmokerChanged,
    required this.onAlcoholChanged,
  });
  final bool isSmoker;
  final AlcoholConsumption alcoholConsumption;
  final ValueChanged<bool> onSmokerChanged;
  final ValueChanged<AlcoholConsumption> onAlcoholChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifestyle', style: AppTypography.title),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Smoker', style: AppTypography.body),
          value: isSmoker,
          onChanged: onSmokerChanged,
          activeThumbColor: AppColors.primary,
        ),
        SizedBox(height: 8.h),
        Text('Alcohol Consumption', style: AppTypography.body),
        SizedBox(height: 4.h),
        SegmentedButton<AlcoholConsumption>(
          segments: AlcoholConsumption.values
              .map((v) => ButtonSegment(
                    value: v,
                    label: Text(v.name[0].toUpperCase() +
                        v.name.substring(1)),
                  ))
              .toList(),
          selected: {alcoholConsumption},
          onSelectionChanged: (s) => onAlcoholChanged(s.first),
        ),
      ],
    );
  }
}
