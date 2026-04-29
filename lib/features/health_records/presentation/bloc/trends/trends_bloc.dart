import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_trends_usecase.dart';
import 'trends_event.dart';
import 'trends_state.dart';

class TrendsBloc extends Bloc<TrendsEvent, TrendsState> {
  TrendsBloc({required GetTrendsUsecase getTrends})
      : _getTrends = getTrends,
        super(const TrendsInitial()) {
    on<TrendsRequested>(_onRequested, transformer: droppable());
    on<TrendsPeriodChanged>(_onPeriodChanged, transformer: restartable());
  }

  final GetTrendsUsecase _getTrends;

  Future<void> _onRequested(
      TrendsRequested event, Emitter<TrendsState> emit) async {
    emit(const TrendsLoading());
    await _fetch(event.days, emit);
  }

  Future<void> _onPeriodChanged(
      TrendsPeriodChanged event, Emitter<TrendsState> emit) async {
    emit(const TrendsLoading());
    await _fetch(event.days, emit);
  }

  Future<void> _fetch(int days, Emitter<TrendsState> emit) async {
    final result = await _getTrends(days: days);
    result.fold(
      (failure) => emit(TrendsFailure(failure.message)),
      (data) => emit(TrendsLoaded(data: data, days: days)),
    );
  }
}
