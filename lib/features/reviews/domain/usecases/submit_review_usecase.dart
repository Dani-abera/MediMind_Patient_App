import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class SubmitReviewUsecase {
  SubmitReviewUsecase(this._repository);
  final ReviewsRepository _repository;

  Future<Either<Failure, void>> call(ReviewSubmission submission) =>
      _repository.submitReview(submission);
}
