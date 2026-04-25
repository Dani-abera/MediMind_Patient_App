class RegisterRequestModel {
  const RegisterRequestModel({
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

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      if (email != null && email!.isNotEmpty) 'email': email,
    };
  }
}
