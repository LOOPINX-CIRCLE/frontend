import 'package:get/get.dart';

class UserTicket {
  final String title;
  final String date;
  final String time;
  final String location;
  final String code;
  final String eventImage;
  final String? invites;
  final String? buttonImage;

  UserTicket({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.code,
    required this.eventImage,
    this.invites,
    this.buttonImage,
  });
}

class UserTicketController extends GetxController {
  var tickets = <UserTicket>[].obs;

  void addTicket(UserTicket ticket) {
    tickets.insert(0, ticket); // Add to beginning of list
  }

  String generateRandomCode() {
    // Generate random 4-digit code
    final random = (1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 10000) / 10000).toInt();
    return random.toString().padLeft(4, '0');
  }
}

