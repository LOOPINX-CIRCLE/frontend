import 'package:flutter/material.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class RequestsEmpty {
  static Future<void> show(BuildContext context, {String? eventName, String? eventPrice, int? confirmedUsers, int? requestsCount}) {
    final count = requestsCount ?? 0;
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabContentUI.getRequestsUI(
        count,
        context,
        eventName: eventName,
        eventPrice: eventPrice,
        confirmedUsers: confirmedUsers,
          ),
    ).then((_) {});
  }
}
