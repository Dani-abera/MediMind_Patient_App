import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteDoctor>>> getFavoriteDoctors();
  Future<Either<Failure, void>> addFavoriteDoctor(String doctorId);
  Future<Either<Failure, void>> removeFavoriteDoctor(String doctorId);
  Future<Either<Failure, List<FavoriteCenter>>> getFavoriteCenters();
  Future<Either<Failure, void>> addFavoriteCenter(String centerId);
  Future<Either<Failure, void>> removeFavoriteCenter(String centerId);
}
