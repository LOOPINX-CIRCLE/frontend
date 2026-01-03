// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';

class EventController extends GetxController {
  var experienceType = "".obs;
  var eventTitle = "".obs;
  var date = "".obs;
  var time = "".obs;
  var duration = "".obs;
  var capacity = "".obs;
  var ticketPrice = "".obs; // ✅ default value
  var description = "".obs;
  var loaction = "".obs;
  var mainLocationName = "".obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var eventImage = "".obs; // Event image for tickets

  // Getter: Date + Time ek sath
  String get dateTime => "${date.value} ${time.value}";
  String get Price => " ${ticketPrice.value}";
  String get event => " ${experienceType.value}";
  String get fullLocation => "${loaction.value} ";

  // Reset method (sab values clear ho jayengi)
  void resetEventData() {
    experienceType.value = "";
    eventTitle.value = "";
    date.value = "";
    time.value = "";
    duration.value = "";
    capacity.value = "0";
    ticketPrice.value = "0"; // default rakhi hai
    description.value = "";
    loaction.value = "";
    mainLocationName.value = "";
    latitude.value = 0.0;
    longitude.value = 0.0;
  }
}
