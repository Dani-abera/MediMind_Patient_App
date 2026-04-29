import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, void>> submitReview(ReviewSubmission submission);
  Future<Either<Failure, List<Review>>> getDoctorReviews(String doctorId);
  Future<Either<Failure, List<Review>>> getCenterReviews(String centerId);
}
