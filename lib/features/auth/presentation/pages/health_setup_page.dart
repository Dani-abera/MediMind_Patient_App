import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/storage/preferences_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../../health_records/presentation/bloc/vitals_form/vitals_form_bloc.dart';
import '../../../health_records/presentation/bloc/vitals_form/vitals_form_event.dart';
import '../../../health_records/presentation/bloc/vitals_form/vitals_form_state.dart';
import '../../../medical_history/domain/entities/medical_history.dart';
import '../../../medical_history/presentation/bloc/medical_history_bloc.dart';
import '../../../medical_history/presentation/bloc/medical_history_event.dart';
import '../../../medical_history/presentation/bloc/medical_history_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

// ── Known data for autocomplete ──────────────────────────────────────────────

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

// ── Page ─────────────────────────────────────────────────────────────────────

class HealthSetupPage extends StatefulWidget {
  const HealthSetupPage({super.key});

  @override
  State<HealthSetupPage> createState() => _HealthSetupPageState();
}

class _HealthSetupPageState extends State<HealthSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _bloodType;

  // Conditions
  bool _hasNoConditions = false;
  final Set<String> _conditions = {};
  final TextEditingController _conditionSearchCtrl = TextEditingController();

  // Allergies
  bool _hasNoAllergies = false;
  final List<Allergy> _allergies = [];
  final TextEditingController _allergenCtrl = TextEditingController();
  AllergenSeverity _newSeverity = AllergenSeverity.mild;

  // Lifestyle
  bool _isSmoker = false;
  AlcoholConsumption _alcohol = AlcoholConsumption.none;

  // Submission step: 0=idle 1=saving medical 2=saving vitals
  int _step = 0;

  static const _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _conditionSearchCtrl.dispose();
    _allergenCtrl.dispose();
    super.dispose();
  }

  void _addAllergy() {
    final name = _allergenCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _allergies.add(Allergy(allergen: name, severity: _newSeverity));
      _allergenCtrl.clear();
      _newSeverity = AllergenSeverity.mild;
    });
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final history = MedicalHistory(
      bloodType: _bloodType,
      chronicConditions:
          _hasNoConditions ? [] : _conditions.toList(),
      allergies:
          _hasNoAllergies ? [] : List.unmodifiable(_allergies),
      isSmoker: _isSmoker,
      alcoholConsumption: _alcohol,
    );

    setState(() => _step = 1);
    context.read<MedicalHistoryBloc>().add(MedicalHistoryUpdated(history));
  }

  Future<void> _completeSetup() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      await sl<PreferencesStorage>()
          .setHealthSetupComplete(authState.user.patientId);
    }
    if (mounted) context.goNamed(RouteNames.home);
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MedicalHistoryBloc, MedicalHistoryState>(
          listener: (context, state) {
            if (state is MedicalHistorySaved && _step == 1) {
              setState(() => _step = 2);
              context.read<VitalsFormBloc>().add(const VitalsFormSubmitted());
            } else if (state is MedicalHistoryFailure && _step == 1) {
              setState(() => _step = 0);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ));
            }
          },
        ),
        BlocListener<VitalsFormBloc, VitalsFormState>(
          listener: (context, state) {
            if (state.status == VitalsFormStatus.success && _step == 2) {
              _completeSetup();
            } else if (state.status == VitalsFormStatus.failure && _step == 2) {
              setState(() => _step = 0);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Failed to save vitals'),
                backgroundColor: AppColors.danger,
              ));
            }
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Health Setup'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set up your health profile',
                      style: AppTypography.headline),
                  SizedBox(height: 6.h),
                  Text(
                    'This information helps us personalise your care.',
                    style: AppTypography.body,
                  ),
                  SizedBox(height: 32.h),

                  // ── Blood Type ──────────────────────────────────
                  _SectionHeader('Blood Type'),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    value: _bloodType,
                    hint: const Text('Select blood type'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                    ),
                    items: _bloodTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _bloodType = v),
                    validator: (_) => _bloodType == null
                        ? 'Please select your blood type'
                        : null,
                  ),
                  SizedBox(height: 28.h),

                  // ── Chronic Conditions ──────────────────────────
                  _SectionHeader('Chronic Conditions'),
                  SizedBox(height: 8.h),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I have no chronic conditions'),
                    value: _hasNoConditions,
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => setState(() {
                      _hasNoConditions = v ?? false;
                      if (_hasNoConditions) _conditions.clear();
                    }),
                  ),
                  if (!_hasNoConditions) ...[
                    SizedBox(height: 8.h),
                    _ConditionAutocomplete(
                      controller: _conditionSearchCtrl,
                      selected: _conditions,
                      onAdd: (c) => setState(() => _conditions.add(c)),
                    ),
                    if (_conditions.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: _conditions
                            .map((c) => Chip(
                                  label: Text(c),
                                  onDeleted: () =>
                                      setState(() => _conditions.remove(c)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                  SizedBox(height: 28.h),

                  // ── Allergies ───────────────────────────────────
                  _SectionHeader('Allergies'),
                  SizedBox(height: 8.h),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I have no known allergies'),
                    value: _hasNoAllergies,
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => setState(() {
                      _hasNoAllergies = v ?? false;
                      if (_hasNoAllergies) _allergies.clear();
                    }),
                  ),
                  if (!_hasNoAllergies) ...[
                    if (_allergies.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      ..._allergies.asMap().entries.map((e) => Card(
                            margin: EdgeInsets.only(bottom: 6.h),
                            child: ListTile(
                              dense: true,
                              title: Text(e.value.allergen),
                              subtitle: Text(e.value.severity.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.danger,
                                iconSize: 20,
                                onPressed: () => setState(
                                    () => _allergies.removeAt(e.key)),
                              ),
                            ),
                          )),
                    ],
                    SizedBox(height: 8.h),
                    _AllergenRow(
                      controller: _allergenCtrl,
                      severity: _newSeverity,
                      onSeverityChanged: (s) =>
                          setState(() => _newSeverity = s),
                      onAdd: _addAllergy,
                    ),
                  ],
                  SizedBox(height: 28.h),

                  // ── Lifestyle ───────────────────────────────────
                  _SectionHeader('Lifestyle'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Do you smoke?'),
                    value: _isSmoker,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isSmoker = v),
                  ),
                  SizedBox(height: 8.h),
                  Text('Alcohol consumption', style: AppTypography.subtitle),
                  SizedBox(height: 8.h),
                  SegmentedButton<AlcoholConsumption>(
                    segments: [
                      ButtonSegment(
                          value: AlcoholConsumption.none, label: const Text('None')),
                      ButtonSegment(
                          value: AlcoholConsumption.occasional,
                          label: const Text('Occasional')),
                      ButtonSegment(
                          value: AlcoholConsumption.regular,
                          label: const Text('Regular')),
                    ],
                    selected: {_alcohol},
                    onSelectionChanged: (s) =>
                        setState(() => _alcohol = s.first),
                  ),
                  SizedBox(height: 28.h),

                  // ── Initial Vitals ──────────────────────────────
                  _SectionHeader('Initial Vitals'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          hint: '170',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                          onChanged: (v) => context
                              .read<VitalsFormBloc>()
                              .add(VitalsFormFieldChanged(
                                  field: 'height', value: v)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          hint: '70',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                          onChanged: (v) => context
                              .read<VitalsFormBloc>()
                              .add(VitalsFormFieldChanged(
                                  field: 'weight', value: v)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),

                  // ── Submit ──────────────────────────────────────
                  BlocBuilder<MedicalHistoryBloc, MedicalHistoryState>(
                    builder: (context, medState) =>
                        BlocBuilder<VitalsFormBloc, VitalsFormState>(
                      builder: (context, vitalsState) {
                        final isLoading = _step > 0 ||
                            medState is MedicalHistorySaving ||
                            vitalsState.status == VitalsFormStatus.loading;
                        return PrimaryButton(
                          label: 'Get Started',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _onSubmit,
                        );
                      },
                    ),
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

// ── Autocomplete widgets ─────────────────────────────────────────────────────

class _ConditionAutocomplete extends StatelessWidget {
  const _ConditionAutocomplete({
    required this.controller,
    required this.selected,
    required this.onAdd,
  });

  final TextEditingController controller;
  final Set<String> selected;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (value) {
        if (value.text.trim().isEmpty) return const [];
        final q = value.text.trim().toLowerCase();
        return _knownConditions
            .where((c) => !selected.contains(c) && c.toLowerCase().contains(q))
            .take(8);
      },
      onSelected: (c) {
        onAdd(c);
        controller.clear();
      },
      fieldViewBuilder: (context, ctrl, focusNode, onSubmit) => TextField(
        controller: ctrl,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: 'Type to search conditions…',
          prefixIcon: const Icon(Icons.search),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  tooltip: 'Add custom condition',
                  onPressed: () {
                    final custom = controller.text.trim();
                    if (custom.isNotEmpty) {
                      onAdd(custom);
                      ctrl.clear();
                    }
                  },
                )
              : null,
        ),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320.w, maxHeight: 240.h),
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
    );
  }
}

class _AllergenRow extends StatelessWidget {
  const _AllergenRow({
    required this.controller,
    required this.severity,
    required this.onSeverityChanged,
    required this.onAdd,
  });

  final TextEditingController controller;
  final AllergenSeverity severity;
  final ValueChanged<AllergenSeverity> onSeverityChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: (value) {
            if (value.text.trim().isEmpty) return const [];
            final q = value.text.trim().toLowerCase();
            return _knownAllergens
                .where((a) => a.toLowerCase().contains(q))
                .take(8);
          },
          onSelected: (_) {},
          fieldViewBuilder: (context, ctrl, focusNode, _) => TextField(
            controller: ctrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Type allergen name…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w, maxHeight: 200.h),
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
        SizedBox(height: 8.h),
        Row(
          children: [
            Text('Severity:', style: AppTypography.subtitle),
            SizedBox(width: 12.w),
            DropdownButton<AllergenSeverity>(
              value: severity,
              underline: const SizedBox(),
              items: AllergenSeverity.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (v) => onSeverityChanged(v!),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: AppTypography.subtitle);
}
