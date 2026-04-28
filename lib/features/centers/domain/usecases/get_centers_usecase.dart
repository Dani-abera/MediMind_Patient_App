import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/center.dart';
import '../repositories/centers_repository.dart';

class CenterFilters extends Equatable {
  const CenterFilters({
    this.city,
    this.specialization,
    this.name,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? city;
  final String? specialization;
  final String? name;
  final int page;
  final int pageSize;

  CenterFilters copyWith({
    String? city,
    String? specialization,
    String? name,
    int? page,
  }) =>
      CenterFilters(
        city: city ?? this.city,
        specialization: specialization ?? this.specialization,
        name: name ?? this.name,
        page: page ?? this.page,
        pageSize: pageSize,
      );

  CenterFilters nextPage() => copyWith(page: page + 1);

  @override
  List<Object?> get props => [city, specialization, name, page, pageSize];
}

class GetCentersUsecase {
  const GetCentersUsecase(this._repository);
  final CentersRepository _repository;

  Future<Either<Failure, List<Center>>> call(CenterFilters filters) =>
      _repository.getCenters(
        city: filters.city,
        specialization: filters.specialization,
        name: filters.name,
        page: filters.page,
        pageSize: filters.pageSize,
      );
}
