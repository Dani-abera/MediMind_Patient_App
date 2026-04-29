import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_latest_prediction_usecase.dart';
import '../../../domain/usecases/get_prediction_by_id_usecase.dart';
import '../../../domain/usecases/get_predictions_usecase.dart';
import '../../../domain/usecases/request_prediction_usecase.dart';
import '../../../../../../features/health_records/domain/usecases/get_record_count_usecase.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  PredictionBloc({
    required RequestPredictionUsecase requestPrediction,
    required GetPredictionsUsecase getPredictions,
    required GetLatestPredictionUsecase getLatestPrediction,
    required GetPredictionByIdUsecase getPredictionById,
    required GetRecordCountUsecase getRecordCount,
  })  : _requestPrediction = requestPrediction,
        _getPredictions = getPredictions,
        _getLatestPrediction = getLatestPrediction,
        _getPredictionById = getPredictionById,
        _getRecordCount = getRecordCount,
        super(const PredictionInitial()) {
    on<PredictionsRequested>(_onListRequested, transformer: droppable());
    on<PredictionRequested>(_onRequested, transformer: droppable());
    on<PredictionDetailRequested>(_onDetailRequested);
  }

  final RequestPredictionUsecase _requestPrediction;
  final GetPredictionsUsecase _getPredictions;
  final GetLatestPredictionUsecase _getLatestPrediction;
  final GetPredictionByIdUsecase _getPredictionById;
  final GetRecordCountUsecase _getRecordCount;

  Future<void> _onListRequested(
      PredictionsRequested event, Emitter<PredictionState> emit) async {
    emit(const PredictionsLoading());
    final listResult = await _getPredictions();
    final latestResult = await _getLatestPrediction();
    listResult.fold(
      (failure) => emit(PredictionFailure(failure.message)),
      (list) => emit(PredictionsLoaded(
        predictions: list,
        latestPrediction: latestResult.fold((_) => null, (r) => r),
      )),
    );
  }

  Future<void> _onRequested(
      PredictionRequested event, Emitter<PredictionState> emit) async {
    final countResult = await _getRecordCount();
    final count = countResult.fold((_) => 0, (c) => c);

    // Confidence level thresholds per spec
    if (count == 0) {
      emit(const PredictionInsufficientData(dataPointsUsed: 0));
      return;
    }

    emit(const PredictionProcessing());
    final result = await _requestPrediction();
    result.fold(
      (failure) => emit(PredictionFailure(failure.message)),
      (prediction) => emit(PredictionSuccess(prediction)),
    );
  }

  Future<void> _onDetailRequested(
      PredictionDetailRequested event,
      Emitter<PredictionState> emit) async {
    emit(const PredictionsLoading());
    final result = await _getPredictionById(event.id);
    result.fold(
      (failure) => emit(PredictionFailure(failure.message)),
      (prediction) => emit(PredictionDetailLoaded(prediction)),
    );
  }
}
