import 'package:get/get.dart';

class TicketPricingController extends GetxController {
  // Reactive state variables
  final isFree = true.obs;
  final ticketPrice = 0.obs;
  final capacity = 100.obs;
  final hasGSTNumber = false.obs;

  // Constants
  static const double guestPlatformFeePercent = 10.0;
  static const double gstPercent = 18.0;

  /// Base ticket price (₹0 if free)
  double get basePricePerTicket =>
      isFree.value ? 0 : ticketPrice.value.toDouble();

  /// Platform fee (10% of base)
  double get guestPlatformFeeAmount =>
      basePricePerTicket * guestPlatformFeePercent / 100.0;

  /// GST on platform fee (18%)
  double get gstOnPlatformFee => guestPlatformFeeAmount * gstPercent / 100.0;

  /// Platform fee including GST
  double get platformFeeIncludingGSTPerTicket =>
      guestPlatformFeeAmount + gstOnPlatformFee;

  /// GST on base (only if host has GST number)
  double get gstOnBasePerTicket =>
      hasGSTNumber.value ? (basePricePerTicket * gstPercent / 100.0) : 0.0;

  /// Final guest price per ticket
  double get guestPaysPerTicket =>
      basePricePerTicket +
      platformFeeIncludingGSTPerTicket +
      gstOnBasePerTicket;

  /// Totals (for all tickets)
  double get totalAmountCollected => guestPaysPerTicket * capacity.value;

  double get totalPlatformFeeCollected =>
      platformFeeIncludingGSTPerTicket * capacity.value;

  double get totalGSTCollected => gstOnBasePerTicket * capacity.value;

  double get estimatedEarnings => basePricePerTicket * capacity.value;

  // Methods to update state
  void toggleIsFree(bool? value) {
    if (value != null) {
      isFree.value = value;
      if (value) {
        ticketPrice.value = 0;
      }
    }
  }

  void toggleHasGSTNumber(bool? value) {
    if (value != null) {
      hasGSTNumber.value = value;
    }
  }

  void updateTicketPrice(String price) {
    int? newPrice = int.tryParse(price);
    if (newPrice != null) {
      ticketPrice.value = newPrice;
      isFree.value = newPrice == 0;
    }
  }

  void updateCapacity(String newCapacity) {
    int? parsedCapacity = int.tryParse(newCapacity);
    if (parsedCapacity != null) {
      capacity.value = parsedCapacity;
    }
  }
}
