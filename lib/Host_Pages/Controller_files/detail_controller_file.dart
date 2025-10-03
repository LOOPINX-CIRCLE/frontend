// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';

class HostPagesController extends GetxController {
  RxBool isEditable = false.obs;
  var isEditable1 = true.obs;
  var isActive = false.obs;
  var progress = 0.0.obs; // ✅ progress bar value (0 → 1)

  FocusNode descFocusNode = FocusNode(); // ✅ Add this
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  RxInt descMaxLines = 1.obs;
  RxBool isButtonEnabled = false.obs;
  RxInt durationInHours = 3.obs; // ✅ Add this line
  RxBool showDurationControls = false.obs;
  var date = ''.obs;
  var time = ''.obs;
  var location = ''.obs;
  var duration = "".obs;
  final EventController eventController = Get.put(EventController());

  @override
  void onInit() {
    super.onInit();
    setDefaultValues();
  }

  void activateButton() {
    isActive.value = true;
  }

  void toggleDurationControls() {
    showDurationControls.value = !showDurationControls.value;
  }

  void updateEventTitle(String value) {
    eventController.eventTitle.value = value;
  }

  void updateDescription(String value) {
    eventController.description.value = value;
  }

  void validateForm() {
    int totalFields = 6; // total required fields
    int filledFields = 0;

    if (titleController.text.trim().isNotEmpty) filledFields++;
    if (descController.text.trim().isNotEmpty) filledFields++;
    if (dateController.text.trim().isNotEmpty) filledFields++;
    if (timeController.text.trim().isNotEmpty) filledFields++;
    if (durationController.text.trim().isNotEmpty) filledFields++;
    if (locationController.text.trim().isNotEmpty) filledFields++;

    // Yaha progress step by step calculate hoga
    progress.value = filledFields / totalFields;

    // Button tabhi enable hoga jab saare fields fill ho
    isButtonEnabled.value = progress.value == 1.0;
  }

  void setDefaultValues() {
    titleController.text = "Event name";
    dateController.text = "DD/MM/YYYY";
    timeController.text = "HH:MM AM";
    durationController.text = "3hr";
    locationController.text = "Enter location";
    descController.text = "";
  }

  void selectDuration(BuildContext context) async {
    duration.value = '3hr';
  }

  void incrementDuration() {
    durationInHours.value++;
    duration.value = "${durationInHours.value}hr";
    durationController.text = duration.value;
    eventController.duration.value = duration.value;
    validateForm();
  }

  void decrementDuration() {
    if (durationInHours.value > 1) {
      durationInHours.value--;
      duration.value = "${durationInHours.value}hr";
      durationController.text = duration.value;
      eventController.duration.value = duration.value;
      validateForm();
    }
  }

  void validateForms() {
    isButtonEnabled.value =
        titleController.text.trim().isNotEmpty &&
        descController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty &&
        durationController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty;
  }

  void resetFields({bool clearEventData = false}) {
    // Reset temporary UI states
    descMaxLines.value = 1;
    isButtonEnabled.value = false;
    progress.value = 0.0;
    isEditable.value = false;
    durationInHours.value = 3;
    duration.value = "";

    // Always reset titleController
    titleController.clear();

    // Clear other controllers only if explicitly requested
    if (clearEventData) {
      descController.clear();
      dateController.clear();
      timeController.clear();
      durationController.clear();
      locationController.clear();

      date.value = "";
      time.value = "";
      location.value = "";
    }

    // Sync EventController values with HostPagesController fields
    eventController.eventTitle.value = titleController.text; // now empty
    eventController.description.value = descController.text;
    eventController.date.value = date.value;
    eventController.time.value = time.value;
    eventController.duration.value = duration.value;
  }

  void makeEditable() {
    titleController.text = "";
    descController.text = "";
    dateController.text = "";
    timeController.text = "";
    durationController.text = "";
    descMaxLines.value = 25;
    isEditable.value = true;
    validateForm();
  }

  void selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      date.value =
          "${picked.day.toString().padLeft(2, "0")}/${picked.month.toString().padLeft(2, "0")}/${picked.year}";
      dateController.text = date.value;
      eventController.date.value = date.value;
      validateForm();
      descFocusNode.unfocus(); // ✅ Correct usage
    }
  }

  void selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode()); // ✅ force remove focus

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = picked.format(context);
      time.value = formattedTime;
      timeController.text = formattedTime;
      eventController.time.value = time.value;
      validateForm();
      descFocusNode.unfocus(); // ✅ Correct usage
    }
  }

  void fillDemoData() {
    titleController.text = "";
    descMaxLines.value = 25;
    isEditable.value = true;
    validateForm();
  }

  @override
  void onClose() {
    super.onClose();
    resetFields();
    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    descFocusNode.dispose();
  }
}
