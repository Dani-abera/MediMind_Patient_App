import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class ProfileSaving extends ProfileState {
  const ProfileSaving(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class ProfileSaved extends ProfileState {
  const ProfileSaved(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
