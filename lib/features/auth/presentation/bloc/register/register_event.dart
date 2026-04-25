import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterFieldChanged extends RegisterEvent {
  const RegisterFieldChanged({required this.field, required this.value});
  final String field;
  final String value;
  @override
  List<Object?> get props => [field, value];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.email,
  });

  final String fullName;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String? email;

  @override
  List<Object?> get props => [fullName, phoneNumber, dateOfBirth, gender, email];
}
