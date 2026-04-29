import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/delete_record_usecase.dart';
import '../../../domain/usecases/get_health_records_usecase.dart';
import '../../../domain/usecases/get_latest_record_usecase.dart';
import '../../../domain/usecases/get_record_count_usecase.dart';
import 'vitals_event.dart';
import 'vitals_state.dart';

class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  VitalsBloc({
    required GetHealthRecordsUsecase getHealthRecords,
    required GetLatestRecordUsecase getLatestRecord,
    required GetRecordCountUsecase getRecordCount,
    required DeleteRecordUsecase deleteRecord,
  })  : _getHealthRecords = getHealthRecords,
        _getLatestRecord = getLatestRecord,
        _getRecordCount = getRecordCount,
        _deleteRecord = deleteRecord,
        super(const VitalsInitial()) {
    on<VitalsRequested>(_onRequested, transformer: droppable());
    on<VitalsRefreshed>(_onRefreshed, transformer: droppable());
    on<VitalRecordDeleted>(_onDeleted);
  }

  final GetHealthRecordsUsecase _getHealthRecords;
  final GetLatestRecordUsecase _getLatestRecord;
  final GetRecordCountUsecase _getRecordCount;
  final DeleteRecordUsecase _deleteRecord;

  Future<void> _onRequested(
      VitalsRequested event, Emitter<VitalsState> emit) async {
    emit(const VitalsLoading());
    await _load(emit, startDate: event.startDate, endDate: event.endDate);
  }

  Future<void> _onRefreshed(
      VitalsRefreshed event, Emitter<VitalsState> emit) async {
    await _load(emit);
  }

  Future<void> _load(
    Emitter<VitalsState> emit, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final recordsResult = await _getHealthRecords(
        startDate: startDate, endDate: endDate);
    final latestResult = await _getLatestRecord();
    final countResult = await _getRecordCount();

    recordsResult.fold(
      (failure) => emit(VitalsFailure(failure.message)),
      (records) => emit(VitalsLoaded(
        records: records,
        latestRecord: latestResult.fold((_) => null, (r) => r),
        totalCount: countResult.fold((_) => 0, (r) => r),
      )),
    );
  }

  Future<void> _onDeleted(
      VitalRecordDeleted event, Emitter<VitalsState> emit) async {
    final result = await _deleteRecord(event.id);
    result.fold(
      (failure) => emit(VitalsFailure(failure.message)),
      (_) => add(const VitalsRefreshed()),
    );
  }
}
