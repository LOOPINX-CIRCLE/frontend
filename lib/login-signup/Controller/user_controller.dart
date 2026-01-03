import 'package:get/get.dart';

class UserController extends GetxController {
  var userName = "".obs;
  var mobileNumber = "".obs;
  var countryCode = "+91".obs;
  var birthDate = "".obs; // Format: DD/MM/YYYY (from input)
  var gender = "".obs; // "Male", "Female", "Others"
  var eventInterests = <int>[].obs; // Array of interest IDs
  var profilePictures = <String>[].obs; // Array of image URLs

  void setUserName(String name) {
    userName.value = name;
  }

  void setMobileNumber(String mobile, {String? code}) {
    mobileNumber.value = mobile;
    if (code != null) {
      countryCode.value = code;
    }
  }

  void setBirthDate(String date) {
    birthDate.value = date; // Store as DD/MM/YYYY
  }

  void setGender(String genderValue) {
    gender.value = genderValue; // Store as "Male", "Female", "Others"
  }

  void setEventInterests(List<int> interests) {
    eventInterests.value = interests;
  }

  void setProfilePictures(List<String> pictures) {
    profilePictures.value = pictures;
  }

  String get fullMobileNumber {
    return "${countryCode.value}${mobileNumber.value}";
  }

  /// Convert birth date from DD/MM/YYYY to YYYY-MM-DD format
  String get formattedBirthDate {
    if (birthDate.value.isEmpty) return "";
    try {
      final parts = birthDate.value.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return "$year-$month-$day"; // YYYY-MM-DD
      }
    } catch (e) {
      print('Error formatting birth date: $e');
    }
    return "";
  }

  /// Convert gender to lowercase API format (male, female, other)
  String get formattedGender {
    final genderValue = gender.value.toLowerCase();
    if (genderValue == "others") return "other";
    return genderValue;
  }

  /// Clear all profile data
  void clearProfileData() {
    userName.value = "";
    mobileNumber.value = "";
    countryCode.value = "+91";
    birthDate.value = "";
    gender.value = "";
    eventInterests.clear();
    profilePictures.clear();
  }
}



















