import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class OtpState extends Equatable {
  const OtpState();
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpSending extends OtpState {
  const OtpSending();
}

class OtpSent extends OtpState {
  const OtpSent({required this.phoneNumber, required this.remainingSeconds});
  final String phoneNumber;
  final int remainingSeconds;
  @override
  List<Object?> get props => [phoneNumber, remainingSeconds];
}

class OtpVerifying extends OtpState {
  const OtpVerifying({required this.phoneNumber, required this.remainingSeconds});
  final String phoneNumber;
  final int remainingSeconds;
  @override
  List<Object?> get props => [phoneNumber, remainingSeconds];
}

class OtpVerified extends OtpState {
  const OtpVerified(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class OtpFailure extends OtpState {
  const OtpFailure({
    required this.message,
    required this.phoneNumber,
    required this.remainingSeconds,
  });
  final String message;
  final String phoneNumber;
  final int remainingSeconds;
  @override
  List<Object?> get props => [message, phoneNumber, remainingSeconds];
}

class OtpExpired extends OtpState {
  const OtpExpired(this.phoneNumber);
  final String phoneNumber;
  @override
  List<Object?> get props => [phoneNumber];
}
