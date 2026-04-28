import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_centers_usecase.dart';
import 'centers_event.dart';
import 'centers_state.dart';

class CentersBloc extends Bloc<CentersEvent, CentersState> {
  CentersBloc({required GetCentersUsecase getCenters})
      : _getCenters = getCenters,
        super(const CentersInitial()) {
    on<CentersRequested>(_onRequested, transformer: droppable());
    on<CentersLoadMore>(_onLoadMore, transformer: droppable());
    on<CentersRefreshed>(_onRefreshed, transformer: droppable());
    on<CenterFavoriteToggled>(_onFavoriteToggled);
  }

  final GetCentersUsecase _getCenters;

  Future<void> _onRequested(
    CentersRequested event,
    Emitter<CentersState> emit,
  ) async {
    emit(const CentersLoading());
    final result = await _getCenters(event.filters);
    result.fold(
      (failure) => emit(CentersError(failure.message)),
      (centers) => emit(CentersLoaded(
        centers: centers,
        hasMore: centers.length >= event.filters.pageSize,
        filters: event.filters,
      )),
    );
  }

  Future<void> _onLoadMore(
    CentersLoadMore event,
    Emitter<CentersState> emit,
  ) async {
    final current = state;
    if (current is! CentersLoaded || !current.hasMore) return;

    emit(CentersLoadingMore(centers: current.centers));
    final nextFilters = current.filters.nextPage();
    final result = await _getCenters(nextFilters);
    result.fold(
      (failure) => emit(CentersLoaded(
        centers: current.centers,
        hasMore: false,
        filters: current.filters,
      )),
      (more) => emit(CentersLoaded(
        centers: [...current.centers, ...more],
        hasMore: more.length >= nextFilters.pageSize,
        filters: nextFilters,
      )),
    );
  }

  Future<void> _onRefreshed(
    CentersRefreshed event,
    Emitter<CentersState> emit,
  ) async {
    final current = state;
    final filters = current is CentersLoaded
        ? current.filters.copyWith(page: 1)
        : const CenterFilters();
    final result = await _getCenters(filters);
    result.fold(
      (failure) => emit(CentersError(failure.message)),
      (centers) => emit(CentersLoaded(
        centers: centers,
        hasMore: centers.length >= filters.pageSize,
        filters: filters,
      )),
    );
  }

  void _onFavoriteToggled(
    CenterFavoriteToggled event,
    Emitter<CentersState> emit,
  ) {
    final current = state;
    if (current is CentersLoaded) {
      emit(current.copyWithFavorite(event.centerId));
    }
  }
}
