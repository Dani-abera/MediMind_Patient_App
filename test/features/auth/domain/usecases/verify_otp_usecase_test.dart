import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/auth/domain/entities/user.dart';
import 'package:medimind/features/auth/domain/repositories/auth_repository.dart';
import 'package:medimind/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyOtpUsecase usecase;
  late MockAuthRepository mockRepository;

  const tPhone = '+251912345678';
  const tOtp = '123456';
  const tParams = VerifyOtpParams(phoneNumber: tPhone, otpCode: tOtp);
  const tUser = User(
    patientId: 'pid-1',
    fullName: 'Test User',
    phoneNumber: tPhone,
    isProfileComplete: false,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = VerifyOtpUsecase(mockRepository);
  });

  group('VerifyOtpUsecase', () {
    test('returns User on success', () async {
      when(() => mockRepository.verifyOtp(
                phoneNumber: tPhone,
                otpCode: tOtp,
              ))
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(() => mockRepository.verifyOtp(
            phoneNumber: tPhone,
            otpCode: tOtp,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns AuthFailure on invalid OTP', () async {
      const failure = AuthFailure(message: 'Invalid OTP');
      when(() => mockRepository.verifyOtp(
                phoneNumber: tPhone,
                otpCode: tOtp,
              ))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left<Failure, User>(failure));
    });

    test('returns NetworkFailure on no internet', () async {
      const failure = NetworkFailure();
      when(() => mockRepository.verifyOtp(
                phoneNumber: any(named: 'phoneNumber'),
                otpCode: any(named: 'otpCode'),
              ))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
