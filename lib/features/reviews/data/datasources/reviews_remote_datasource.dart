import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/review.dart';

abstract class ReviewsRemoteDataSource {
  Future<void> submitReview(ReviewSubmission submission);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  ReviewsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<void> submitReview(ReviewSubmission submission) async {
    try {
      await _dio.post(
        '/appointments/${submission.appointmentId}/review',
        data: {
          'doctorRating': submission.doctorRating,
          'centerRating': submission.centerRating,
          if (submission.doctorComment != null)
            'doctorComment': submission.doctorComment,
          if (submission.centerComment != null)
            'centerComment': submission.centerComment,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
