import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_latest_prediction_usecase.dart';
import '../../../domain/usecases/get_prediction_by_id_usecase.dart';
import '../../../domain/usecases/get_prediction_status_usecase.dart';
import '../../../domain/usecases/get_predictions_usecase.dart';
import '../../../domain/usecases/request_prediction_usecase.dart';
import '../../../../../../core/error/failures.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  PredictionBloc({
    required RequestPredictionUsecase requestPrediction,
    required GetPredictionsUsecase getPredictions,
    required GetLatestPredictionUsecase getLatestPrediction,
    required GetPredictionByIdUsecase getPredictionById,
    required GetPredictionStatusUsecase getPredictionStatus,
  })  : _requestPrediction = requestPrediction,
        _getPredictions = getPredictions,
        _getLatestPrediction = getLatestPrediction,
        _getPredictionById = getPredictionById,
        _getPredictionStatus = getPredictionStatus,
        super(const PredictionInitial()) {
    on<PredictionsRequested>(_onListRequested, transformer: droppable());
    on<PredictionRequested>(_onRequested, transformer: droppable());
    on<PredictionDetailRequested>(_onDetailRequested);
  }

  final RequestPredictionUsecase _requestPrediction;
  final GetPredictionsUsecase _getPredictions;
  final GetLatestPredictionUsecase _getLatestPrediction;
  final GetPredictionByIdUsecase _getPredictionById;
  final GetPredictionStatusUsecase _getPredictionStatus;

  Future<void> _onListRequested(
      PredictionsRequested event, Emitter<PredictionState> emit) async {
    emit(const PredictionsLoading());
    final listResult = await _getPredictions();
    final latestResult = await _getLatestPrediction();
    final statusResult = await _getPredictionStatus();
    listResult.fold(
      (failure) => emit(PredictionFailure(_mapFailure(failure))),
      (list) => emit(PredictionsLoaded(
        predictions: list,
        latestPrediction: latestResult.fold((_) => null, (r) => r),
        status: statusResult.fold((_) => null, (s) => s),
      )),
    );
  }

  Future<void> _onRequested(
      PredictionRequested event, Emitter<PredictionState> emit) async {
    final statusResult = await _getPredictionStatus();
    final status = statusResult.fold((_) => null, (s) => s);

    // Only block when the server explicitly says the user cannot request yet.
    // If the status call itself failed (network/auth error), fall through and
    // let the backend validate — it will return the appropriate error.
    if (status != null && !status.canRequest) {
      emit(PredictionInsufficientData(
        dataPointsUsed: status.healthRecordCount,
        canRequestPrediction: false,
        message: status.message,
      ));
      return;
    }

    emit(const PredictionProcessing());
    final result = await _requestPrediction();
    result.fold(
      (failure) => emit(PredictionFailure(_mapFailure(failure))),
      (prediction) => emit(PredictionSuccess(prediction)),
    );
  }

  Future<void> _onDetailRequested(
      PredictionDetailRequested event,
      Emitter<PredictionState> emit) async {
    emit(const PredictionsLoading());
    final result = await _getPredictionById(event.id);
    result.fold(
      (failure) => emit(PredictionFailure(_mapFailure(failure))),
      (prediction) => emit(PredictionDetailLoaded(prediction)),
    );
  }

  static String _mapFailure(Failure failure) {
    return switch (failure) {
      NetworkFailure() =>
        'No internet connection. Please check your connection and try again.',
      ServerFailure(code: 503) =>
        'Our AI is temporarily unavailable. Please try again in a few minutes.',
      ServerFailure(code: 404) =>
        'The prediction was not found.',
      ServerFailure(code: 403) =>
        'You do not have permission to view this prediction.',
      ServerFailure(code: 401) =>
        'Your session has expired. Please log in again.',
      ValidationFailure(:final message) => message,
      AuthFailure() =>
        'Your session has expired. Please log in again.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
