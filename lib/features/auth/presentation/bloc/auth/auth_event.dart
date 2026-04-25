import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class UserLoggedIn extends AuthEvent {
  const UserLoggedIn(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class UserLoggedOut extends AuthEvent {
  const UserLoggedOut();
}

class TokenExpired extends AuthEvent {
  const TokenExpired();
}
