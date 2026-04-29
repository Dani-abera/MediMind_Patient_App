import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({
    required this.doctors,
    required this.centers,
  });
  final List<FavoriteDoctor> doctors;
  final List<FavoriteCenter> centers;
  @override List<Object?> get props => [doctors, centers];
}

class FavoritesFailure extends FavoritesState {
  const FavoritesFailure(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
