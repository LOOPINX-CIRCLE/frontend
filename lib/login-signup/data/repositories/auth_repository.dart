import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';

import '../models/send_otp_response.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SendOtpResponse> sendOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        body: {
          'phone_number': phoneNumber,
        },
      );

      return SendOtpResponse.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to process your request right now.', error: error);
    }
  }
}

