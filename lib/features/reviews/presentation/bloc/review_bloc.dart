import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/submit_review_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc({required this.submitReview}) : super(const ReviewState()) {
    on<ReviewDoctorRatingChanged>(
        (e, emit) => emit(state.copyWith(doctorRating: e.rating)));
    on<ReviewCenterRatingChanged>(
        (e, emit) => emit(state.copyWith(centerRating: e.rating)));
    on<ReviewDoctorCommentChanged>(
        (e, emit) => emit(state.copyWith(doctorComment: e.comment)));
    on<ReviewCenterCommentChanged>(
        (e, emit) => emit(state.copyWith(centerComment: e.comment)));
    on<ReviewSubmitted>(_onSubmitted);
  }

  final SubmitReviewUsecase submitReview;

  Future<void> _onSubmitted(
      ReviewSubmitted event, Emitter<ReviewState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(errorMessage: 'Please rate both doctor and center'));
      return;
    }
    emit(state.copyWith(isSubmitting: true));
    final result = await submitReview(ReviewSubmission(
      appointmentId: event.appointmentId,
      doctorRating: state.doctorRating,
      centerRating: state.centerRating,
      doctorComment:
          state.doctorComment.isNotEmpty ? state.doctorComment : null,
      centerComment:
          state.centerComment.isNotEmpty ? state.centerComment : null,
    ));
    result.fold(
      (f) => emit(state.copyWith(
          isSubmitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(isSubmitting: false, isSuccess: true)),
    );
  }
}
