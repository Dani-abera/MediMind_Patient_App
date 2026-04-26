import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeOpened extends HomeEvent {
  const HomeOpened();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
