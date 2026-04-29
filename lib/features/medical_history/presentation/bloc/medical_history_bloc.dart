import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_medical_history_usecase.dart';
import '../../domain/usecases/update_medical_history_usecase.dart';
import 'medical_history_event.dart';
import 'medical_history_state.dart';

class MedicalHistoryBloc
    extends Bloc<MedicalHistoryEvent, MedicalHistoryState> {
  MedicalHistoryBloc({
    required this.getMedicalHistory,
    required this.updateMedicalHistory,
  }) : super(const MedicalHistoryInitial()) {
    on<MedicalHistoryRequested>(_onRequested);
    on<MedicalHistoryUpdated>(_onUpdated);
  }

  final GetMedicalHistoryUsecase getMedicalHistory;
  final UpdateMedicalHistoryUsecase updateMedicalHistory;

  Future<void> _onRequested(
      MedicalHistoryRequested event, Emitter<MedicalHistoryState> emit) async {
    emit(const MedicalHistoryLoading());
    final result = await getMedicalHistory();
    result.fold(
      (f) => emit(MedicalHistoryFailure(f.message)),
      (h) => emit(MedicalHistoryLoaded(h)),
    );
  }

  Future<void> _onUpdated(
      MedicalHistoryUpdated event, Emitter<MedicalHistoryState> emit) async {
    emit(MedicalHistorySaving(event.history));
    final result = await updateMedicalHistory(event.history);
    result.fold(
      (f) => emit(MedicalHistoryFailure(f.message)),
      (h) => emit(MedicalHistorySaved(h)),
    );
  }
}
