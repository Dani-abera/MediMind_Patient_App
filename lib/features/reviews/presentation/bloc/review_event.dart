import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override List<Object?> get props => [];
}

class ReviewDoctorRatingChanged extends ReviewEvent {
  const ReviewDoctorRatingChanged(this.rating);
  final int rating;
  @override List<Object?> get props => [rating];
}

class ReviewCenterRatingChanged extends ReviewEvent {
  const ReviewCenterRatingChanged(this.rating);
  final int rating;
  @override List<Object?> get props => [rating];
}

class ReviewDoctorCommentChanged extends ReviewEvent {
  const ReviewDoctorCommentChanged(this.comment);
  final String comment;
  @override List<Object?> get props => [comment];
}

class ReviewCenterCommentChanged extends ReviewEvent {
  const ReviewCenterCommentChanged(this.comment);
  final String comment;
  @override List<Object?> get props => [comment];
}

class ReviewSubmitted extends ReviewEvent {
  const ReviewSubmitted(this.appointmentId);
  final String appointmentId;
  @override List<Object?> get props => [appointmentId];
}
