class ApiConstants {
  static const String baseUrl = 'https://loopinbackend-g17e.onrender.com/api';
  static const Duration defaultTimeout = Duration(seconds: 180); // Increased to 180 seconds (3 minutes) for image uploads
  static const Duration otpTimeout = Duration(seconds: 120); // Specific timeout for OTP endpoints
  static const Duration imageUploadTimeout = Duration(seconds: 240); // Specific timeout for image uploads (4 minutes)
}

