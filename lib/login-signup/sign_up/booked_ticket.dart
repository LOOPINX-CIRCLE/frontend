
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/login-signup/sign_up/share_invite.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';

class BookedTicket extends StatefulWidget {
  const BookedTicket({super.key, this.showTabs = true});

  final bool showTabs;

  @override
  State<BookedTicket> createState() => _BookedTicketState();
}

class _BookedTicketState extends State<BookedTicket> {
  final UserTicketController ticketController = Get.put(UserTicketController());

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTabs) ...[
                const SizedBox(height: 8),
                // Top tabs like on Home_pages, with My tickets highlighted
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const BottomBar(initialIndex: 0),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.07)),
                          ),
                          child: const Text(
                            "Discover",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          "My tickets",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const SizedBox(height: 8),
              // Dynamically generated tickets from controller
              Obx(() => Column(
                children: ticketController.tickets.map((ticket) => TicketCard(
                  image: ticket.eventImage,
                  title: ticket.title,
                  date: ticket.date,
                  time: ticket.time,
                  location: ticket.location,
                  code: ticket.code,
                  invites: ticket.invites,
                  buttonImage: ticket.buttonImage,
                )).toList(),
              )),
              // Static tickets (can be kept for demo)
              const TicketCard(
                image: "assets/images/frame1.png",
                title: "Beauty Queen",
                date: "17 July, 2025",
                time: "2:00 PM",
                location: "Romeo Lane, Dehradun",
                code: "1998",
                // invites: "+3 Invites",
                // buttonImage: "assets/images/share_Invite.png",
              ),
              const TicketCard(
                image: "assets/images/frame2.png",
                title: "Tyler Event",
                date: "23 September, 2025",
                time: "8:00 PM",
                location: "Bastian, Bangalore",
                code: "3654",
              ),
              const TicketCard(
                image: "assets/images/frame3.png",
                title: "Pickle Ball",
                date: "27 July, 2025",
                time: "4:00 PM",
                location: "Underdoggs, Dehradun",
                code: "3864",
              ),
              const SizedBox(height: 24),
            ],
          ),
    );

    if (widget.showTabs) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          child: content,
        ),
      );
    } else {
      return content;
    }
  }
}


class TicketCard extends StatelessWidget {
  final String image;
  final String title;
  final String date;
  final String time;
  final String location;
  final String code;
  final String? invites; // optional invite badge
  final String? buttonImage; // 👈 new param for button

  const TicketCard({
    super.key,
    required this.image,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.code,
    this.invites,
    this.buttonImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment(-1.0, -0.5),
                    end: Alignment(1.0, 0.5),
                    colors: [
                      Color.fromRGBO(27, 27, 27, 0.6),
                      Color.fromRGBO(60, 60, 60, 0.42),
                      Color.fromRGBO(27, 27, 27, 0.6),
                    ],
                    stops: [0.2984, 0.5878, 0.9065],
                  ),
                  border: Border.all(
                    color: Color.fromRGBO(255, 255, 255, 0.13),
                    width: 1,
                  ),
                ),
      child: Stack(
        children: [
          Row(
            children: [
              // Event image with invite tag
              SizedBox(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    if (invites != null)
                      Positioned(
                        bottom: -10,
                        left: 12,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          alignment: const Alignment(0, 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            invites!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          image,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Event details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "BricolageGrotesque",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            'assets/images/dot.png',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 40.0),
                        child: const Divider(
                          color: Colors.white24,
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset('assets/images/Map Point.png', width: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset('assets/images/key.png', width: 14),
                          const SizedBox(width: 4),
                          const Text(
                            "Secret Code ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 👇 Button in bottom-right corner
          if (buttonImage != null)
  Positioned(
    bottom: 7,
    right: 8,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Invite()),
        );
      },
      child: Image.asset(
        buttonImage!,
        width: 85,
      ),
    ),
  ),
        ],
      ),
    );
  }
}
