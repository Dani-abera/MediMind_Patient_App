import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.userId,
    required super.userType,
    required super.fullName,
    required super.isProfileComplete,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'],
      userType: json['userType'],
      fullName: json['fullName'],
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
