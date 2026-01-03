import 'package:flutter/material.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class ConfirmedEmpty {
  static Future<void> show(BuildContext context, {int? confirmedCount}) {
    final count = confirmedCount ?? 0;
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabContentUI.getConfirmedUI(
        count,
      context,
      ),
    ).then((_) {});
  }
}
