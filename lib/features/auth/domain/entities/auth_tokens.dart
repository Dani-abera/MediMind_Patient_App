import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userType,
    required this.fullName,
    required this.isProfileComplete,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String userType;
  final String fullName;
  final bool isProfileComplete;

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    userId,
    userType,
    fullName,
    isProfileComplete,
  ];
}
