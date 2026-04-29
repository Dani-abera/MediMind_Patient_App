import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated({
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
  });
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;

  @override
  List<Object?> get props => [fullName, email, dateOfBirth, gender];
}

class ProfileImageUploaded extends ProfileEvent {
  const ProfileImageUploaded(this.filePath);
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

class ProfileImageDeleted extends ProfileEvent {
  const ProfileImageDeleted();
}
