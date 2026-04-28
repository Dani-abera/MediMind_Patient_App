import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center.dart';
import '../entities/center_detail.dart';

abstract class CentersRepository {
  Future<Either<Failure, List<Center>>> getCenters({
    String? city,
    String? specialization,
    String? name,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, List<Center>>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  });

  Future<Either<Failure, CenterDetail>> getCenterDetail(String centerId);
}
