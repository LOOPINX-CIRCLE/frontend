import 'package:get/get.dart';

class CityController extends GetxController {
  var selectedCity = 'Dehradun'.obs;

  final cities = [
    {"name": "Bengaluru", "image": "assets/icons/Ellipse 1 (1).png"},
    {"name": "Delhi", "image": "assets/icons/Ellipse 1.png"},
    {"name": "Mumbai", "image": "assets/icons/Ellipse 1 (2).png"},
    {"name": "Dehradun", "image": "assets/icons/Ellipse 1 (3).png"},
  ];
  void selectCity(String city) {
    selectedCity.value = city;
    Get.back();
  }
}
