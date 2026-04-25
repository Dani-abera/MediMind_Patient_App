import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/auth/domain/entities/user.dart';
import 'package:medimind/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:medimind/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:medimind/features/auth/presentation/bloc/otp/otp_bloc.dart';
import 'package:medimind/features/auth/presentation/bloc/otp/otp_event.dart';
import 'package:medimind/features/auth/presentation/bloc/otp/otp_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestOtpUsecase extends Mock implements RequestOtpUsecase {}

class MockVerifyOtpUsecase extends Mock implements VerifyOtpUsecase {}

void main() {
  late MockRequestOtpUsecase mockRequestOtp;
  late MockVerifyOtpUsecase mockVerifyOtp;

  const tPhone = '+251912345678';
  const tOtp = '123456';
  const tUser = User(
    patientId: 'pid-1',
    fullName: 'Test User',
    phoneNumber: tPhone,
    isProfileComplete: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const VerifyOtpParams(phoneNumber: tPhone, otpCode: tOtp),
    );
  });

  setUp(() {
    mockRequestOtp = MockRequestOtpUsecase();
    mockVerifyOtp = MockVerifyOtpUsecase();
  });

  OtpBloc buildBloc() => OtpBloc(
        requestOtp: mockRequestOtp,
        verifyOtp: mockVerifyOtp,
      );

  group('OtpRequested', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpSending, OtpSent] on success',
      build: () {
        when(() => mockRequestOtp(phoneNumber: tPhone))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const OtpRequested(tPhone)),
      expect: () => [
        const OtpSending(),
        isA<OtpSent>()
            .having((s) => s.phoneNumber, 'phone', tPhone)
            .having((s) => s.remainingSeconds, 'remaining', 300),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpSending, OtpFailure] on server error',
      build: () {
        when(() => mockRequestOtp(phoneNumber: tPhone)).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Server error', code: 500)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const OtpRequested(tPhone)),
      expect: () => [
        const OtpSending(),
        isA<OtpFailure>().having(
          (s) => s.message,
          'message',
          'Server error',
        ),
      ],
    );
  });

  group('OtpSubmitted', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpVerifying, OtpVerified] on success',
      build: () {
        when(() => mockVerifyOtp(any()))
            .thenAnswer((_) async => const Right(tUser));
        return buildBloc();
      },
      seed: () => const OtpSent(phoneNumber: tPhone, remainingSeconds: 250),
      act: (bloc) => bloc.add(
        const OtpSubmitted(phoneNumber: tPhone, otpCode: tOtp),
      ),
      expect: () => [
        isA<OtpVerifying>(),
        isA<OtpVerified>().having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpVerifying, OtpFailure] on invalid OTP',
      build: () {
        when(() => mockVerifyOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid OTP')),
        );
        return buildBloc();
      },
      seed: () => const OtpSent(phoneNumber: tPhone, remainingSeconds: 200),
      act: (bloc) => bloc.add(
        const OtpSubmitted(phoneNumber: tPhone, otpCode: '000000'),
      ),
      expect: () => [
        isA<OtpVerifying>(),
        isA<OtpFailure>()
            .having((s) => s.message, 'message', 'Invalid OTP'),
      ],
    );
  });

  group('OtpTimerTicked', () {
    blocTest<OtpBloc, OtpState>(
      'emits OtpExpired when remainingSeconds reaches 0',
      build: buildBloc,
      seed: () => const OtpSent(phoneNumber: tPhone, remainingSeconds: 1),
      act: (bloc) => bloc.add(const OtpTimerTicked(0)),
      expect: () => [isA<OtpExpired>()],
    );

    blocTest<OtpBloc, OtpState>(
      'updates remainingSeconds in OtpSent state',
      build: buildBloc,
      seed: () => const OtpSent(phoneNumber: tPhone, remainingSeconds: 100),
      act: (bloc) => bloc.add(const OtpTimerTicked(99)),
      expect: () => [
        isA<OtpSent>().having((s) => s.remainingSeconds, 'remaining', 99),
      ],
    );
  });
}
