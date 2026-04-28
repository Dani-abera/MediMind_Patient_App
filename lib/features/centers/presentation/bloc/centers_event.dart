import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_centers_usecase.dart';

abstract class CentersEvent extends Equatable {
  const CentersEvent();
  @override
  List<Object?> get props => [];
}

class CentersRequested extends CentersEvent {
  const CentersRequested({this.filters = const CenterFilters()});
  final CenterFilters filters;
  @override
  List<Object?> get props => [filters];
}

class CentersLoadMore extends CentersEvent {
  const CentersLoadMore();
}

class CentersRefreshed extends CentersEvent {
  const CentersRefreshed();
}

class CenterFavoriteToggled extends CentersEvent {
  const CenterFavoriteToggled(this.centerId);
  final String centerId;
  @override
  List<Object?> get props => [centerId];
}
