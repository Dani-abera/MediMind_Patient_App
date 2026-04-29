import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_prescription_usecase.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';
import 'prescriptions_event.dart';
import 'prescriptions_state.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {
  PrescriptionsBloc({
    required this.getPrescriptions,
    required this.getPrescription,
  }) : super(const PrescriptionsInitial()) {
    on<PrescriptionsRequested>(_onRequested);
    on<PrescriptionsRefreshed>(_onRequested);
    on<PrescriptionDetailRequested>(_onDetailRequested);
  }

  final GetPrescriptionsUsecase getPrescriptions;
  final GetPrescriptionUsecase getPrescription;

  Future<void> _onRequested(
      PrescriptionsEvent event, Emitter<PrescriptionsState> emit) async {
    emit(const PrescriptionsLoading());
    final result = await getPrescriptions();
    result.fold(
      (f) => emit(PrescriptionsFailure(f.message)),
      (list) => emit(PrescriptionsLoaded(list)),
    );
  }

  Future<void> _onDetailRequested(
      PrescriptionDetailRequested event, Emitter<PrescriptionsState> emit) async {
    emit(const PrescriptionsLoading());
    final result = await getPrescription(event.id);
    result.fold(
      (f) => emit(PrescriptionsFailure(f.message)),
      (p) => emit(PrescriptionDetailLoaded(p)),
    );
  }
}
