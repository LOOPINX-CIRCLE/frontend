class SendOtpResponse {
  const SendOtpResponse({
    required this.success,
    required this.message,
    this.data,
    this.token,
  });

  final bool success;
  final String message;
  final SendOtpData? data;
  final String? token;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? SendOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      token: json['token']?.toString(),
    );
  }

  factory SendOtpResponse.error(String message) {
    return SendOtpResponse(success: false, message: message, data: null, token: null);
  }
}

class SendOtpData {
  const SendOtpData({
    required this.phoneNumber,
    required this.userStatus,
    required this.otpSent,
  });

  final String phoneNumber;
  final String userStatus;
  final bool otpSent;

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      phoneNumber: json['phone_number']?.toString() ?? '',
      userStatus: json['user_status']?.toString() ?? '',
      otpSent: json['otp_sent'] as bool? ?? false,
    );
  }
}

