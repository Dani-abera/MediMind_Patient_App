import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override List<Object?> get props => [];
}

class FavoritesRequested extends FavoritesEvent {
  const FavoritesRequested();
}

class FavoriteDoctorToggled extends FavoritesEvent {
  const FavoriteDoctorToggled(this.doctorId, {required this.isFavorite});
  final String doctorId;
  final bool isFavorite;
  @override List<Object?> get props => [doctorId, isFavorite];
}

class FavoriteCenterToggled extends FavoritesEvent {
  const FavoriteCenterToggled(this.centerId, {required this.isFavorite});
  final String centerId;
  final bool isFavorite;
  @override List<Object?> get props => [centerId, isFavorite];
}
