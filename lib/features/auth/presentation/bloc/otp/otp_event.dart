import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
  @override
  List<Object?> get props => [];
}

class OtpRequested extends OtpEvent {
  const OtpRequested(this.phoneNumber);
  final String phoneNumber;
  @override
  List<Object?> get props => [phoneNumber];
}

class OtpSubmitted extends OtpEvent {
  const OtpSubmitted({required this.phoneNumber, required this.otpCode});
  final String phoneNumber;
  final String otpCode;
  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

class OtpResendRequested extends OtpEvent {
  const OtpResendRequested(this.phoneNumber);
  final String phoneNumber;
  @override
  List<Object?> get props => [phoneNumber];
}

class OtpTimerTicked extends OtpEvent {
  const OtpTimerTicked(this.remainingSeconds);
  final int remainingSeconds;
  @override
  List<Object?> get props => [remainingSeconds];
}
