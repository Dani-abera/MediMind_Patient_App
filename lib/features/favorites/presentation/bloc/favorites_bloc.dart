import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required this.repository})
      : super(const FavoritesInitial()) {
    on<FavoritesRequested>(_onRequested);
    on<FavoriteDoctorToggled>(_onDoctorToggled);
    on<FavoriteCenterToggled>(_onCenterToggled);
  }

  final FavoritesRepository repository;

  Future<void> _onRequested(
      FavoritesRequested event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesLoading());
    final doctors = await repository.getFavoriteDoctors();
    final centers = await repository.getFavoriteCenters();
    final docList = doctors.fold((f) => null, (d) => d);
    final cenList = centers.fold((f) => null, (c) => c);
    if (docList == null || cenList == null) {
      final msg = doctors.fold((f) => f.message, (_) => '') +
          centers.fold((f) => f.message, (_) => '');
      emit(FavoritesFailure(msg.isNotEmpty ? msg : 'Failed to load favorites'));
    } else {
      emit(FavoritesLoaded(doctors: docList, centers: cenList));
    }
  }

  Future<void> _onDoctorToggled(
      FavoriteDoctorToggled event, Emitter<FavoritesState> emit) async {
    if (event.isFavorite) {
      await repository.addFavoriteDoctor(event.doctorId);
    } else {
      await repository.removeFavoriteDoctor(event.doctorId);
      if (state is FavoritesLoaded) {
        final current = state as FavoritesLoaded;
        emit(FavoritesLoaded(
          doctors: current.doctors
              .where((d) => d.doctorId != event.doctorId)
              .toList(),
          centers: current.centers,
        ));
      }
    }
  }

  Future<void> _onCenterToggled(
      FavoriteCenterToggled event, Emitter<FavoritesState> emit) async {
    if (event.isFavorite) {
      await repository.addFavoriteCenter(event.centerId);
    } else {
      await repository.removeFavoriteCenter(event.centerId);
      if (state is FavoritesLoaded) {
        final current = state as FavoritesLoaded;
        emit(FavoritesLoaded(
          doctors: current.doctors,
          centers: current.centers
              .where((c) => c.centerId != event.centerId)
              .toList(),
        ));
      }
    }
  }
}
