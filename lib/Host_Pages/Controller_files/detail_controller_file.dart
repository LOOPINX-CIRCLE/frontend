// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';

class HostPagesController extends GetxController {
  // ---------------- Rx Variables ----------------
  RxBool isEditable = false.obs;
  var isEditable1 = true.obs;
  var isActive = false.obs;
  var progress = 0.0.obs;
  RxInt descMaxLines = 1.obs;
  RxBool isButtonEnabled = false.obs;
  RxInt durationInHours = 3.obs;
  RxBool showDurationControls = false.obs;

  var date = ''.obs;
  var time = ''.obs;
  var location = ''.obs;
  var duration = ''.obs;

  // ---------------- Controllers ----------------
  FocusNode descFocusNode = FocusNode();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  // ---------------- Event Controller ----------------
  final EventController eventController = Get.put(EventController());

  @override
  void onInit() {
    super.onInit();
    resetController(clearEventData: true); // ✅ always start clean
  }

  // ---------------- Default Values ----------------
  void setDefaultValues() {
    titleController.text = "Event name";
    dateController.text = "DD/MM/YYYY";
    timeController.text = "HH:MM AM";
    durationController.text = "3hr";
    locationController.text = "Enter location";
    descController.text = "";
  }

  // ---------------- Reset Controller ----------------
  void resetController({bool clearEventData = true}) {
    isEditable.value = false;
    isEditable1.value = true;
    isActive.value = false;
    progress.value = 0.0;
    descMaxLines.value = 1;
    isButtonEnabled.value = false;
    durationInHours.value = 3;
    showDurationControls.value = false;

    date.value = '';
    time.value = '';
    location.value = '';
    duration.value = '';

    titleController.clear();
    descController.clear();
    locationController.clear();
    dateController.clear();
    timeController.clear();
    durationController.clear();

    if (clearEventData) {
      eventController.eventTitle.value = '';
      eventController.description.value = '';
      eventController.date.value = '';
      eventController.time.value = '';
      eventController.duration.value = '';
    }
  }

  // ---------------- Validation ----------------
  void validateForm() {
    int totalFields = 6;
    int filledFields = 0;

    if (titleController.text.trim().isNotEmpty) filledFields++;
    if (descController.text.trim().isNotEmpty) filledFields++;
    if (dateController.text.trim().isNotEmpty) filledFields++;
    if (timeController.text.trim().isNotEmpty) filledFields++;
    if (durationController.text.trim().isNotEmpty) filledFields++;
    if (locationController.text.trim().isNotEmpty) filledFields++;

    progress.value = filledFields / totalFields;
    isButtonEnabled.value = progress.value == 1.0;
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

  // ---------------- Editable ----------------
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

  void activateButton() {
    isActive.value = true;
  }

  void toggleDurationControls() {
    showDurationControls.value = !showDurationControls.value;
  }

  // ---------------- Duration ----------------
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

  // ---------------- Date & Time Picker ----------------
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
      descFocusNode.unfocus();
    }
  }

  void selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
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
      descFocusNode.unfocus();
    }
  }

  void fillDemoData() {
    titleController.text = "";
    descMaxLines.value = 25;
    isEditable.value = true;
    validateForm();
  }

  void updateEventTitle(String value) {
    eventController.eventTitle.value = value;
  }

  void updateDescription(String value) {
    eventController.description.value = value;
  }

  // ---------------- OnClose ----------------
  @override
  void onClose() {
    resetController(clearEventData: true);
    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    descFocusNode.dispose();
    super.onClose();
  }
}
