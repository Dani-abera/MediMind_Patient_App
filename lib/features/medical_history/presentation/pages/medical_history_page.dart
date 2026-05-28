import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../domain/entities/medical_history.dart';
import '../bloc/medical_history_bloc.dart';
import '../bloc/medical_history_event.dart';
import '../bloc/medical_history_state.dart';

// ── Autocomplete data ─────────────────────────────────────────────────────────

const _knownConditions = [
  'Diabetes', 'Type 1 Diabetes', 'Type 2 Diabetes', 'Hypertension',
  'Asthma', 'Heart Disease', 'Coronary Artery Disease', 'Atrial Fibrillation',
  'Heart Failure', 'Chronic Kidney Disease', 'Kidney Disease', 'Liver Disease',
  'Cirrhosis', 'Thyroid Disorder', 'Hypothyroidism', 'Hyperthyroidism',
  'Arthritis', 'Rheumatoid Arthritis', 'Osteoarthritis', 'Gout', 'Cancer',
  'COPD', 'Emphysema', 'Chronic Bronchitis', 'Epilepsy', 'Seizure Disorder',
  'Multiple Sclerosis', "Parkinson's Disease", "Alzheimer's Disease",
  'Dementia', 'Depression', 'Anxiety', 'Bipolar Disorder', 'Schizophrenia',
  'Obesity', 'High Cholesterol', 'Dyslipidemia', 'Anemia', 'Sickle Cell Disease',
  'Hemophilia', 'HIV/AIDS', 'Hepatitis B', 'Hepatitis C', 'Tuberculosis',
  'Malaria', 'Stroke', 'Peptic Ulcer', 'Inflammatory Bowel Disease',
  "Crohn's Disease", 'Ulcerative Colitis', 'Celiac Disease', 'Lupus',
  'Fibromyalgia', 'Migraine', 'Psoriasis', 'Eczema', 'Glaucoma', 'Cataracts',
];

const _knownAllergens = [
  'Penicillin', 'Amoxicillin', 'Ampicillin', 'Aspirin', 'Ibuprofen',
  'NSAIDs', 'Sulfonamides', 'Codeine', 'Morphine', 'Tetracycline',
  'Cephalosporins', 'Metformin', 'Latex', 'Peanuts', 'Tree Nuts', 'Almonds',
  'Cashews', 'Walnuts', 'Shellfish', 'Shrimp', 'Crab', 'Lobster', 'Fish',
  'Milk', 'Dairy', 'Eggs', 'Wheat', 'Gluten', 'Soy', 'Sesame',
  'Bee Stings', 'Wasp Stings', 'Cat Dander', 'Dog Dander', 'Dust Mites',
  'Pollen', 'Grass Pollen', 'Mold', 'Cockroach', 'Nickel', 'Fragrance',
];

// ── Page ──────────────────────────────────────────────────────────────────────

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
    context.read<MedicalHistoryBloc>().add(MedicalHistoryUpdated(_draft));
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
          final isSaving = state is MedicalHistorySaving;
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BloodTypeSection(
                            value: _draft.bloodType,
                            onChanged: (v) =>
                                _update(_draft.copyWith(bloodType: v)),
                          ),
                          SizedBox(height: 20.h),
                          _AutocompleteChipsSection(
                            title: 'Chronic Conditions',
                            items: _draft.chronicConditions,
                            suggestions: _knownConditions,
                            hint: 'Type to search conditions…',
                            onChanged: (list) => _update(
                                _draft.copyWith(chronicConditions: list)),
                          ),
                          SizedBox(height: 20.h),
                          _AllergiesSection(
                            allergies: _draft.allergies,
                            onChanged: (list) =>
                                _update(_draft.copyWith(allergies: list)),
                          ),
                          SizedBox(height: 20.h),
                          _AutocompleteChipsSection(
                            title: 'Family History',
                            items: _draft.familyHistory,
                            suggestions: _knownConditions,
                            hint: 'Type to search conditions…',
                            onChanged: (list) =>
                                _update(_draft.copyWith(familyHistory: list)),
                          ),
                          SizedBox(height: 20.h),
                          _LifestyleSection(
                            isSmoker: _draft.isSmoker,
                            alcoholConsumption: _draft.alcoholConsumption,
                            onSmokerChanged: (v) =>
                                _update(_draft.copyWith(isSmoker: v)),
                            onAlcoholChanged: (v) =>
                                _update(_draft.copyWith(alcoholConsumption: v)),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: PrimaryButton(
                      label: 'Save Changes',
                      isLoading: isSaving,
                      onPressed: (_dirty && !isSaving) ? _save : null,
                    ),
                  ),
                ],
              ),
              if (isSaving)
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

// ── Blood type ────────────────────────────────────────────────────────────────

class _BloodTypeSection extends StatelessWidget {
  const _BloodTypeSection({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _types = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
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

// ── Chips section with autocomplete ──────────────────────────────────────────

class _AutocompleteChipsSection extends StatefulWidget {
  const _AutocompleteChipsSection({
    required this.title,
    required this.items,
    required this.suggestions,
    required this.hint,
    required this.onChanged,
  });

  final String title;
  final List<String> items;
  final List<String> suggestions;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_AutocompleteChipsSection> createState() =>
      _AutocompleteChipsSectionState();
}

class _AutocompleteChipsSectionState
    extends State<_AutocompleteChipsSection> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || widget.items.contains(trimmed)) return;
    widget.onChanged([...widget.items, trimmed]);
    _ctrl.clear();
  }

  void _remove(String item) {
    widget.onChanged(widget.items.where((e) => e != item).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: AppTypography.title),
        SizedBox(height: 8.h),

        // Autocomplete input
        RawAutocomplete<String>(
          textEditingController: _ctrl,
          focusNode: _focusNode,
          optionsBuilder: (value) {
            if (value.text.trim().isEmpty) return const [];
            final q = value.text.trim().toLowerCase();
            return widget.suggestions
                .where((s) =>
                    !widget.items.contains(s) &&
                    s.toLowerCase().contains(q))
                .take(8);
          },
          onSelected: _add,
          fieldViewBuilder: (context, ctrl, focusNode, _) => TextField(
            controller: ctrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.primary,
                      tooltip: 'Add custom entry',
                      onPressed: () => _add(ctrl.text),
                    )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
            ),
          ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8.r),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 320.w, maxHeight: 220.h),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  shrinkWrap: true,
                  children: options
                      .map((opt) => ListTile(
                            dense: true,
                            title: Text(opt),
                            onTap: () => onSelected(opt),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),

        // Selected chips
        if (widget.items.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: widget.items
                .map((item) => Chip(
                      label: Text(item, style: AppTypography.caption),
                      onDeleted: () => _remove(item),
                    ))
                .toList(),
          ),
        ] else ...[
          SizedBox(height: 6.h),
          Text('None added', style: AppTypography.caption),
        ],
      ],
    );
  }
}

// ── Allergies section ─────────────────────────────────────────────────────────

class _AllergiesSection extends StatefulWidget {
  const _AllergiesSection({required this.allergies, required this.onChanged});
  final List<Allergy> allergies;
  final ValueChanged<List<Allergy>> onChanged;

  @override
  State<_AllergiesSection> createState() => _AllergiesSectionState();
}

class _AllergiesSectionState extends State<_AllergiesSection> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  AllergenSeverity _severity = AllergenSeverity.mild;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    widget.onChanged([
      ...widget.allergies,
      Allergy(allergen: name, severity: _severity),
    ]);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Allergies', style: AppTypography.title),
        SizedBox(height: 8.h),

        // Existing allergy list
        if (widget.allergies.isNotEmpty) ...[
          ...widget.allergies.map((a) {
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
                    child: Text(
                      a.severity.name[0].toUpperCase() +
                          a.severity.name.substring(1),
                      style:
                          AppTypography.caption.copyWith(color: severityColor),
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onChanged(
                        widget.allergies.where((x) => x != a).toList()),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
        ] else ...[
          Text('None added', style: AppTypography.caption),
          SizedBox(height: 8.h),
        ],

        // Allergen autocomplete input
        RawAutocomplete<String>(
          textEditingController: _ctrl,
          focusNode: _focusNode,
          optionsBuilder: (value) {
            if (value.text.trim().isEmpty) return const [];
            final q = value.text.trim().toLowerCase();
            return _knownAllergens
                .where((a) => a.toLowerCase().contains(q))
                .take(8);
          },
          onSelected: (v) {
            _ctrl.text = v;
            _ctrl.selection = TextSelection.collapsed(offset: v.length);
          },
          fieldViewBuilder: (context, ctrl, focusNode, _) => TextField(
            controller: ctrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Type allergen name…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
            ),
          ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8.r),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 280.w, maxHeight: 200.h),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  shrinkWrap: true,
                  children: options
                      .map((opt) => ListTile(
                            dense: true,
                            title: Text(opt),
                            onTap: () => onSelected(opt),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),

        // Severity + Add button row
        SizedBox(height: 8.h),
        Row(
          children: [
            Text('Severity:', style: AppTypography.subtitle),
            SizedBox(width: 12.w),
            DropdownButton<AllergenSeverity>(
              value: _severity,
              underline: const SizedBox(),
              items: AllergenSeverity.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.name[0].toUpperCase() + s.name.substring(1),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _severity = v!),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Lifestyle section ─────────────────────────────────────────────────────────

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
                    label: Text(
                        v.name[0].toUpperCase() + v.name.substring(1)),
                  ))
              .toList(),
          selected: {alcoholConsumption},
          onSelectionChanged: (s) => onAlcoholChanged(s.first),
        ),
      ],
    );
  }
}
