import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._dataSource);
  final FavoritesRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<FavoriteDoctor>>> getFavoriteDoctors() async {
    try { return Right(await _dataSource.getFavoriteDoctors()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> addFavoriteDoctor(String doctorId) async {
    try { await _dataSource.addFavoriteDoctor(doctorId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> removeFavoriteDoctor(String doctorId) async {
    try { await _dataSource.removeFavoriteDoctor(doctorId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, List<FavoriteCenter>>> getFavoriteCenters() async {
    try { return Right(await _dataSource.getFavoriteCenters()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> addFavoriteCenter(String centerId) async {
    try { await _dataSource.addFavoriteCenter(centerId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> removeFavoriteCenter(String centerId) async {
    try { await _dataSource.removeFavoriteCenter(centerId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
}
