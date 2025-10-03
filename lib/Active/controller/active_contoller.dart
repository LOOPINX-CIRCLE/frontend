import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankController extends GetxController {
  final nameController = TextEditingController();
  final bankController = TextEditingController();
  final accountController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();
  FocusNode ifscFocusNode = FocusNode();

  RxBool isMismatch = false.obs;
  RxBool isActive = false.obs;

  void checkMatch() {
    isMismatch.value = accountController.text != confirmAccountController.text;
  }

  void checkFields() {
    isActive.value = nameController.text.isNotEmpty;
  }

  void clearAll() {
    nameController.clear();
    bankController.clear();
    accountController.clear();
    confirmAccountController.clear();
    ifscController.clear();
    isMismatch.value = false;
  }
}
