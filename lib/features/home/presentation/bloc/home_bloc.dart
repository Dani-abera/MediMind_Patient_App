import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeDataUsecase getHomeData})
      : _getHomeData = getHomeData,
        super(const HomeInitial()) {
    on<HomeOpened>(_onOpened);
    on<HomeRefreshed>(_onRefreshed);
  }

  final GetHomeDataUsecase _getHomeData;

  Future<void> _onOpened(HomeOpened event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _load(emit);
  }

  Future<void> _onRefreshed(
      HomeRefreshed event, Emitter<HomeState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<HomeState> emit) async {
    try {
      final result = await _getHomeData();
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (data) {
          if (data.failedSections.isEmpty) {
            emit(HomeLoaded(data));
          } else {
            emit(HomePartialLoaded(data: data, errors: data.failedSections));
          }
        },
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
