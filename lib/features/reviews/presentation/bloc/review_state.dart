import 'package:equatable/equatable.dart';

class ReviewState extends Equatable {
  const ReviewState({
    this.doctorRating = 0,
    this.centerRating = 0,
    this.doctorComment = '',
    this.centerComment = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final int doctorRating;
  final int centerRating;
  final String doctorComment;
  final String centerComment;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  bool get isValid => doctorRating > 0 && centerRating > 0;

  ReviewState copyWith({
    int? doctorRating,
    int? centerRating,
    String? doctorComment,
    String? centerComment,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) =>
      ReviewState(
        doctorRating: doctorRating ?? this.doctorRating,
        centerRating: centerRating ?? this.centerRating,
        doctorComment: doctorComment ?? this.doctorComment,
        centerComment: centerComment ?? this.centerComment,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        doctorRating, centerRating, doctorComment, centerComment,
        isSubmitting, isSuccess, errorMessage,
      ];
}
