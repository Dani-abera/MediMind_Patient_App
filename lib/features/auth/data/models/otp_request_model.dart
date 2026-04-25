class OtpRequestModel {
  const OtpRequestModel({required this.phoneNumber});
  final String phoneNumber;

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

class OtpVerifyRequestModel {
  const OtpVerifyRequestModel({
    required this.phoneNumber,
    required this.otpCode,
  });

  final String phoneNumber;
  final String otpCode;

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
      };
}
