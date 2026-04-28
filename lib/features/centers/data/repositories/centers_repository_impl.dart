import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/center.dart';
import '../../domain/entities/center_detail.dart';
import '../../domain/repositories/centers_repository.dart';
import '../datasources/centers_remote_datasource.dart';

class CentersRepositoryImpl implements CentersRepository {
  const CentersRepositoryImpl(this._remoteDataSource);
  final CentersRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Center>>> getCenters({
    String? city,
    String? specialization,
    String? name,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getCenters(
        city: city,
        specialization: specialization,
        name: name,
        page: page,
        pageSize: pageSize,
      );
      return Right(models);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Center>>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final models = await _remoteDataSource.getNearbyCenters(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(models);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CenterDetail>> getCenterDetail(
      String centerId) async {
    try {
      final model = await _remoteDataSource.getCenterDetail(centerId);
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
