import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/log_vitals_usecase.dart';
import 'vitals_form_event.dart';
import 'vitals_form_state.dart';

class VitalsFormBloc extends Bloc<VitalsFormEvent, VitalsFormState> {
  VitalsFormBloc({required LogVitalsUsecase logVitals})
      : _logVitals = logVitals,
        super(const VitalsFormState()) {
    on<VitalsFormFieldChanged>(_onFieldChanged);
    on<VitalsFormSubmitted>(_onSubmitted);
    on<VitalsFormReset>(_onReset);
  }

  final LogVitalsUsecase _logVitals;

  void _onFieldChanged(
      VitalsFormFieldChanged event, Emitter<VitalsFormState> emit) {
    var updated = _applyField(state, event.field, event.value);
    updated = updated.copyWith(errors: _validate(updated));
    emit(updated);
  }

  VitalsFormState _applyField(
      VitalsFormState s, String field, String value) {
    return switch (field) {
      'systolic' => s.copyWith(systolic: value),
      'diastolic' => s.copyWith(diastolic: value),
      'glucose' => s.copyWith(glucose: value),
      'weight' => s.copyWith(weight: value),
      'height' => s.copyWith(height: value),
      'heartRate' => s.copyWith(heartRate: value),
      'temperature' => s.copyWith(temperature: value),
      'oxygenSaturation' => s.copyWith(oxygenSaturation: value),
      'respiratoryRate' => s.copyWith(respiratoryRate: value),
      'notes' => s.copyWith(notes: value),
      _ => s,
    };
  }

  Map<String, String> _validate(VitalsFormState s) {
    final errors = <String, String>{};

    double? parse(String v) =>
        v.isEmpty ? null : double.tryParse(v);

    final sys = parse(s.systolic);
    final dia = parse(s.diastolic);

    if (s.systolic.isNotEmpty && sys == null) {
      errors['systolic'] = 'Enter a valid number';
    }
    if (s.diastolic.isNotEmpty && dia == null) {
      errors['diastolic'] = 'Enter a valid number';
    }
    // FR-005: Systolic must be higher than diastolic BP
    if (sys != null && dia != null && sys <= dia) {
      errors['systolic'] = 'Systolic must be higher than diastolic BP';
    }
    if (s.glucose.isNotEmpty && parse(s.glucose) == null) {
      errors['glucose'] = 'Enter a valid number';
    }
    if (s.weight.isNotEmpty && parse(s.weight) == null) {
      errors['weight'] = 'Enter a valid number';
    }
    if (s.height.isNotEmpty && parse(s.height) == null) {
      errors['height'] = 'Enter a valid number';
    }
    if (s.heartRate.isNotEmpty && parse(s.heartRate) == null) {
      errors['heartRate'] = 'Enter a valid number';
    }
    if (s.temperature.isNotEmpty && parse(s.temperature) == null) {
      errors['temperature'] = 'Enter a valid number';
    }
    if (s.oxygenSaturation.isNotEmpty &&
        parse(s.oxygenSaturation) == null) {
      errors['oxygenSaturation'] = 'Enter a valid number';
    }
    if (s.respiratoryRate.isNotEmpty &&
        parse(s.respiratoryRate) == null) {
      errors['respiratoryRate'] = 'Enter a valid number';
    }

    final o2 = parse(s.oxygenSaturation);
    if (o2 != null && (o2 < 0 || o2 > 100)) {
      errors['oxygenSaturation'] = 'Must be between 0 and 100';
    }

    return errors;
  }

  Future<void> _onSubmitted(
      VitalsFormSubmitted event, Emitter<VitalsFormState> emit) async {
    final errors = _validate(state);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }

    emit(state.copyWith(
        status: VitalsFormStatus.loading, errors: const {}));

    double? p(String v) => v.isEmpty ? null : double.tryParse(v);

    final params = LogVitalsParams(
      recordId: event.recordId,
      bloodPressureSystolic: p(state.systolic),
      bloodPressureDiastolic: p(state.diastolic),
      glucoseLevel: p(state.glucose),
      weight: p(state.weight),
      height: p(state.height),
      heartRate: p(state.heartRate),
      temperature: p(state.temperature),
      oxygenSaturation: p(state.oxygenSaturation),
      respiratoryRate: p(state.respiratoryRate),
      notes: state.notes.isEmpty ? null : state.notes,
    );

    final result = await _logVitals(params);
    result.fold(
      (failure) => emit(state.copyWith(
        status: VitalsFormStatus.failure,
        errorMessage: failure.message,
      )),
      (record) => emit(state.copyWith(
        status: VitalsFormStatus.success,
        savedRecord: record,
      )),
    );
  }

  void _onReset(VitalsFormReset event, Emitter<VitalsFormState> emit) =>
      emit(const VitalsFormState());
}
