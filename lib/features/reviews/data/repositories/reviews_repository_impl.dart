import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  ReviewsRepositoryImpl(this._dataSource);
  final ReviewsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, void>> submitReview(ReviewSubmission submission) async {
    try { await _dataSource.submitReview(submission); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, List<Review>>> getDoctorReviews(String doctorId) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Review>>> getCenterReviews(String centerId) async =>
      const Right([]);
}
