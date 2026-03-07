import 'package:flutter/material.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class CheckInEmpty {
  static void show(
    BuildContext context, {
    int? checkInCount,
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
    int? eventId,
  }) {
    final count = checkInCount ?? 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabContentUI.getCheckInUI(
        count,
        context,
        eventName: eventName,
        eventPrice: eventPrice,
        confirmedUsers: confirmedUsers,
        eventId: eventId,
      ),
    );
  }
}

