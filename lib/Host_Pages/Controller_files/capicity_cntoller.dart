// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/navigation_bar.dart';

class CapacityController extends GetxController {
  // ------------------- Inject EventController -------------------
  final EventController eventController = Get.put(EventController());

  // ------------------- UI/State -------------------
  RxBool isFreeTicket = false.obs; // Free ticket toggle
  RxBool isGSTIncluded = false.obs; // GST toggle
  RxBool isActive = false.obs;

  TextEditingController capacityController = TextEditingController();
  TextEditingController ticketPriceController = TextEditingController();

  RxDouble previousTicketPrice = 0.0.obs;

  RxBool isTotalOpen = false.obs;
  RxBool isGuestFeeOpen = false.obs;

  // ------------------- Outputs -------------------
  var guestPays = 0.0.obs; // Guest final price
  var totalAmount = 0.0.obs; // Total ticket sales
  var platformFee = 0.0.obs; // Total platform fee
  var estimateEarning = 0.0.obs; // Base earnings
  var yourEarning = 0.0.obs; // Host actual earning

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  // ------------------- Core Vars -------------------
  final isFree = true.obs;
  final ticketPrice = 0.obs;
  final capacity = 0.obs;
  final hasGSTNumber = false.obs;

  // Constants
  static const double guestPlatformFeePercent = 10.0;
  static const double gstPercent = 18.0;

  // ------------------- Getters -------------------
  double get basePricePerTicket =>
      isFree.value ? 0 : ticketPrice.value.toDouble();

  double get guestPlatformFeeAmount =>
      basePricePerTicket * guestPlatformFeePercent / 100.0;

  double get gstOnPlatformFee => guestPlatformFeeAmount * gstPercent / 100.0;

  double get platformFeeIncludingGSTPerTicket =>
      guestPlatformFeeAmount + gstOnPlatformFee;

  double get gstOnBasePerTicket =>
      hasGSTNumber.value ? (basePricePerTicket * gstPercent / 100.0) : 0.0;

  double get guestPaysPerTicket =>
      basePricePerTicket +
      platformFeeIncludingGSTPerTicket +
      gstOnBasePerTicket;

  int get totalAmountCollected =>
      ticketPrice.value * capacity.value + totalPlatformFeeCollected.toInt();

  double get totalPlatformFeeCollected =>
      platformFeeIncludingGSTPerTicket * capacity.value;
  double get totalGSTCollected =>
      hasGSTNumber.value ? (totalAmountCollected * gstPercent / 100.0) : 0.0;

  double get estimatedEarnings => basePricePerTicket * capacity.value;

  // ------------------- Methods -------------------
  void resetFields() {
    isFreeTicket.value = false;
    isGSTIncluded.value = false;
    isActive.value = false;

    capacityController.clear();
    ticketPriceController.clear();

    guestPays.value = 0.0;
    totalAmount.value = 0.0;
    platformFee.value = 0.0;
    estimateEarning.value = 0.0;
    yourEarning.value = 0.0;

    previousTicketPrice.value = 0.0;
    isTotalOpen.value = false;
    isGuestFeeOpen.value = false;
  }

  void updatePreviousTicketPrice(double value) {
    previousTicketPrice.value = value;
    ticketPriceController.text = value.toStringAsFixed(0);
  }

  void toggleFree() {
    isFreeTicket.value = !isFreeTicket.value;
    if (isFreeTicket.value) {
      previousTicketPrice.value =
          double.tryParse(ticketPriceController.text) ??
          previousTicketPrice.value;
      ticketPriceController.text = "0";
      updateTicketPrice("0");
    } else {
      ticketPriceController.text = previousTicketPrice.value.toStringAsFixed(0);
      updateTicketPrice(ticketPriceController.text);
    }
    checkIfActive();
  }

  void toggleGST() {
    isGSTIncluded.value = !isGSTIncluded.value;
    toggleHasGSTNumber(isGSTIncluded.value);
    recalculate();
  }

  void checkIfActive() {
    if (capacityController.text.isNotEmpty) {
      isActive.value = true;
    } else {
      isActive.value = false;
    }
  }

  void toggleIsFree(bool value) {
    isFreeTicket.value = value;
    isFree.value = value;

    if (value) {
      ticketPriceController.text = "0";
      updateTicketPrice("0");
    } else {
      if (previousTicketPrice.value > 0) {
        ticketPriceController.text = previousTicketPrice.value.toStringAsFixed(
          0,
        );
        updateTicketPrice(ticketPriceController.text);
      }
    }
    checkIfActive();
  }

  void toggleHasGSTNumber(bool? value) {
    if (value != null) {
      hasGSTNumber.value = value;
    }
  }

  // ✅ Ticket Price update + sync EventController
  void updateTicketPrice(String price) {
    int? newPrice = int.tryParse(price);
    if (newPrice != null) {
      ticketPrice.value = newPrice;
      isFree.value = newPrice == 0;

      // Sync EventController
      eventController.ticketPrice.value = newPrice.toString();

      recalculate();
    }
  }

  // ✅ Capacity update + sync EventController
  void updateCapacity(String value) {
    int? parsedCapacity = int.tryParse(value);
    if (parsedCapacity != null) {
      capacity.value = parsedCapacity;

      // Sync EventController
      eventController.capacity.value = parsedCapacity.toString();

      checkIfActive();
      recalculate();
    }
  }

  void recalculate() {
    guestPays.value = guestPaysPerTicket;
    totalAmount.value = guestPaysPerTicket * capacity.value;
    platformFee.value = totalPlatformFeeCollected;
    estimateEarning.value = estimatedEarnings;
    yourEarning.value = estimatedEarnings; // 👈 host earning (without GST)
  }

  @override
  void onClose() {
    capacityController.dispose();
    ticketPriceController.dispose();
    super.onClose();
    Get.delete<CapacityController>();
  }
}
