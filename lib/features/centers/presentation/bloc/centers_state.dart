import 'package:equatable/equatable.dart';
import '../../domain/entities/center.dart';
import '../../domain/usecases/get_centers_usecase.dart';

abstract class CentersState extends Equatable {
  const CentersState();
  @override
  List<Object?> get props => [];
}

class CentersInitial extends CentersState {
  const CentersInitial();
}

class CentersLoading extends CentersState {
  const CentersLoading();
}

class CentersLoaded extends CentersState {
  const CentersLoaded({
    required this.centers,
    required this.hasMore,
    required this.filters,
  });

  final List<Center> centers;
  final bool hasMore;
  final CenterFilters filters;

  CentersLoaded copyWithFavorite(String centerId) => CentersLoaded(
        centers: centers
            .map((c) => c.id == centerId ? c.copyWith(isFavorite: !c.isFavorite) : c)
            .toList(),
        hasMore: hasMore,
        filters: filters,
      );

  @override
  List<Object?> get props => [centers, hasMore, filters];
}

class CentersLoadingMore extends CentersState {
  const CentersLoadingMore({required this.centers});
  final List<Center> centers;
  @override
  List<Object?> get props => [centers];
}

class CentersError extends CentersState {
  const CentersError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
