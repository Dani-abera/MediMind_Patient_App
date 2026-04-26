import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);
  final HomeData data;
  @override
  List<Object?> get props => [data];
}

class HomePartialLoaded extends HomeState {
  const HomePartialLoaded({required this.data, required this.errors});
  final HomeData data;
  final List<String> errors;
  @override
  List<Object?> get props => [data, errors];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
