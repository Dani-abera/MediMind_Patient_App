import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center.dart';
import '../repositories/centers_repository.dart';

class GetNearbyCentersUsecase {
  const GetNearbyCentersUsecase(this._repository);
  final CentersRepository _repository;

  Future<Either<Failure, List<Center>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) =>
      _repository.getNearbyCenters(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
}
