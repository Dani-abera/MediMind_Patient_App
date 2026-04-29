import 'package:equatable/equatable.dart';

class ReviewSubmission extends Equatable {
  const ReviewSubmission({
    required this.appointmentId,
    required this.doctorRating,
    required this.centerRating,
    this.doctorComment,
    this.centerComment,
  });

  final String appointmentId;
  final int doctorRating;
  final int centerRating;
  final String? doctorComment;
  final String? centerComment;

  @override
  List<Object?> get props => [
        appointmentId, doctorRating, centerRating,
        doctorComment, centerComment,
      ];
}

class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    required this.reviewerName,
    required this.createdAt,
    this.comment,
  });

  final String id;
  final int rating;
  final String reviewerName;
  final DateTime createdAt;
  final String? comment;

  @override
  List<Object?> get props =>
      [id, rating, reviewerName, createdAt, comment];
}
