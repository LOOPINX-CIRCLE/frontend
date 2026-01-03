import 'package:flutter/material.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class InvitedEmpty {
  static Future<void> show(
    BuildContext context, {
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
    int? invitedCount,
    VoidCallback? onUsersInvited,
  }) {
    final count = invitedCount ?? 0;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabContentUI.getInvitedUI(
        count,
        context,
        eventName: eventName,
        eventPrice: eventPrice,
        confirmedUsers: confirmedUsers,
        onUsersInvited: onUsersInvited,
      ),
    ).then((_) {});
    }
  }
