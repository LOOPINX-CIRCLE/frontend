import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../data/models/send_otp_response.dart';
import '../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final RxBool isSendingOtp = false.obs;

  Future<SendOtpResponse> sendOtp(String phoneNumber) async {
    if (isSendingOtp.value) {
      return SendOtpResponse.error('Please wait for the current request to complete.');
    }

    try {
      isSendingOtp.value = true;
      final response = await _repository.sendOtp(phoneNumber);
      return response;
    } on ApiException catch (error) {
      if (Get.isLogEnable) {
        // ignore: avoid_print
        print('AuthController.sendOtp ApiException: ${error.message} | ${error.error}');
      }
      return SendOtpResponse.error(error.message);
    } catch (error, stackTrace) {
      if (Get.isLogEnable) {
        // ignore: avoid_print
        print('AuthController.sendOtp unexpected error: $error');
        // ignore: avoid_print
        print(stackTrace);
      }
      return SendOtpResponse.error('Something went wrong. Please try again.');
    } finally {
      isSendingOtp.value = false;
    }
  }
}

