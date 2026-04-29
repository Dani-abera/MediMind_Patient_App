import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/reviews/domain/entities/review.dart';
import 'package:medimind/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:medimind/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:medimind/features/reviews/presentation/bloc/review_event.dart';
import 'package:medimind/features/reviews/presentation/bloc/review_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmitReviewUsecase extends Mock implements SubmitReviewUsecase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ReviewSubmission(
      appointmentId: '',
      doctorRating: 0,
      centerRating: 0,
    ));
  });

  late MockSubmitReviewUsecase mockSubmit;

  setUp(() {
    mockSubmit = MockSubmitReviewUsecase();
  });

  ReviewBloc build() => ReviewBloc(submitReview: mockSubmit);

  test('initial state has zero ratings and isValid=false', () {
    final bloc = build();
    expect(bloc.state.doctorRating, 0);
    expect(bloc.state.centerRating, 0);
    expect(bloc.state.isValid, false);
    bloc.close();
  });

  group('rating changes', () {
    blocTest<ReviewBloc, ReviewState>(
      'updates doctorRating',
      build: build,
      act: (b) => b.add(const ReviewDoctorRatingChanged(4)),
      expect: () => [
        isA<ReviewState>()
            .having((s) => s.doctorRating, 'doctorRating', 4),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'isValid when both ratings set',
      build: build,
      act: (b) {
        b.add(const ReviewDoctorRatingChanged(5));
        b.add(const ReviewCenterRatingChanged(4));
      },
      expect: () => [
        isA<ReviewState>().having((s) => s.doctorRating, 'doctorRating', 5),
        isA<ReviewState>()
            .having((s) => s.isValid, 'isValid', true),
      ],
    );
  });

  group('ReviewSubmitted', () {
    blocTest<ReviewBloc, ReviewState>(
      'emits error when invalid (missing ratings)',
      build: build,
      act: (b) => b.add(const ReviewSubmitted('appt1')),
      expect: () => [
        isA<ReviewState>()
            .having((s) => s.errorMessage, 'error', isNotNull),
      ],
      verify: (_) => verifyNever(() => mockSubmit(any())),
    );

    blocTest<ReviewBloc, ReviewState>(
      'emits [isSubmitting=true, isSuccess=true] on valid submit',
      setUp: () => when(() => mockSubmit(any()))
          .thenAnswer((_) async => const Right(null)),
      build: build,
      seed: () => const ReviewState(doctorRating: 5, centerRating: 4),
      act: (b) => b.add(const ReviewSubmitted('appt1')),
      expect: () => [
        isA<ReviewState>()
            .having((s) => s.isSubmitting, 'submitting', true),
        isA<ReviewState>()
            .having((s) => s.isSuccess, 'success', true),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'emits failure message on server error',
      setUp: () => when(() => mockSubmit(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error'))),
      build: build,
      seed: () => const ReviewState(doctorRating: 3, centerRating: 3),
      act: (b) => b.add(const ReviewSubmitted('appt1')),
      expect: () => [
        isA<ReviewState>()
            .having((s) => s.isSubmitting, 'submitting', true),
        isA<ReviewState>()
            .having((s) => s.errorMessage, 'error', 'Server error'),
      ],
    );
  });
}
