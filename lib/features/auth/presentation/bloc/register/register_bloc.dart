import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/register_patient_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required RegisterPatientUsecase registerPatient})
      : _registerPatient = registerPatient,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterPatientUsecase _registerPatient;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (!_validate(event, emit)) return;
    emit(const RegisterLoading());
    final result = await _registerPatient(
      RegisterPatientParams(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        email: event.email,
      ),
    );
    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (_) => emit(RegisterSuccess(event.phoneNumber)),
    );
  }

  bool _validate(RegisterSubmitted event, Emitter<RegisterState> emit) {
    if (event.fullName.trim().isEmpty) {
      emit(const RegisterFailure('Full name is required'));
      return false;
    }
    if (event.phoneNumber.trim().isEmpty) {
      emit(const RegisterFailure('Phone number is required'));
      return false;
    }
    if (event.dateOfBirth.trim().isEmpty) {
      emit(const RegisterFailure('Date of birth is required'));
      return false;
    }
    if (event.gender.trim().isEmpty) {
      emit(const RegisterFailure('Gender is required'));
      return false;
    }
    return true;
  }
}
