import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/core/services/event_request_service.dart';


class Invite extends StatefulWidget {
  final int eventId;
  
  const Invite({super.key, this.eventId = 0});

  @override
  State<Invite> createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  List<Map<String, String>> contacts = [
    {"name": "Senan Muhammed", "phone": "99664 44678"},
    {"name": "Meet Suthar", "phone": "99664 44678"},
    {"name": "Arjun Patel", "phone": "99664 12345"},
    {"name": "Priya Sharma", "phone": "99664 98765"},
    {"name": "joe Verma", "phone": "99664 11111"},
    {"name": "Rahul Verma", "phone": "99664 11111"},
    {"name": "Rahul Verma", "phone": "99664 11111"},
    {"name": "pratham", "phone": "99664 11111"},
    {"name": "Avantika", "phone": "99664 11111"},
    {"name": "pratham", "phone": "99664 11111"},
    {"name": "Mamta Kumari", "phone": "99664 11111"},
  ];

  String searchQuery = "";
  String _shareUrl = ""; // Real share URL from backend
  
  Set<String> selectedContacts = {};

  late EventRequestService _eventRequestService;

  @override
  void initState() {
    super.initState();
    _eventRequestService = EventRequestService();
    
    // Fetch the share URL if eventId is provided
    if (widget.eventId > 0) {
      _fetchShareUrl();
    }
  }

  Future<void> _fetchShareUrl() async {
    try {
      final url = await _eventRequestService.getEventShareUrl(widget.eventId);
      
      if (mounted) {
        setState(() {
          _shareUrl = url;
        });
      }
      
      if (kDebugMode) {
        print('✅ Share URL loaded: $_shareUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching share URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter and sort contacts by search
    List<Map<String, String>> filteredContacts =
        contacts
            .where(
              (c) =>
                  c["name"]!.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    filteredContacts.sort((a, b) => a["name"]!.compareTo(b["name"]!));

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    "Share Invite",
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Left section with texts, line, subtitle, icons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            "Quick Share",
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Line
                          Container(
                            height: 1,
                            width: 170,
                            color: const Color(0xFF424242),
                          ),

                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            "Send your invite link instantly",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Social icons row
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/social_icons.png",
                                width: 200,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🔹 Right side Share Invite button
                    GestureDetector(
                      onTap: () async {
                        if (_shareUrl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Loading share URL...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        
                        final shareMessage = 'Check out this awesome event! 🎉\nJoin here 👉 $_shareUrl';
                        
                        SharePlus.instance.share(
                          ShareParams(
                            text: shareMessage,
                          ),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            center: Alignment(0.0, -0.71),
                            radius: 0.8,
                            colors: [Color(0xFFB78EF5), Color(0xFF6F1CEB)],
                            stops: [0.0, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/images/Share.png",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- SEPARATOR ----------
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Text("or", style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 3),

              // ---------- CONTACTS ----------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment(-1.0, -0.5), // approx for 112deg
                    end: Alignment(1.0, 0.5),
                    colors: [
                      Color.fromRGBO(27, 27, 27, 0.6), // rgba(27, 27, 27, 0.60)
                      Color.fromRGBO(
                        108,
                        107,
                        107,
                        0.42,
                      ), // rgba(60, 60, 60, 0.42)
                      Color.fromRGBO(27, 27, 27, 0.6), // rgba(27, 27, 27, 0.60)
                    ],
                    stops: [0.2984, 0.5878, 0.9065],
                  ),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.13),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose from Contacts",
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 200, // custom width
                      height: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFF424242)),
                      ),
                    ),

                    const SizedBox(height: 2),
                    Text(
                      "Pick who gets the invite",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),

                    SizedBox(
                      width: 320,
                      height: 40, // 🔹 fixed height
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13, // 🔹 smaller text size
                        ),
                        decoration: InputDecoration(
                          hintText: "Search contacts",
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13, // 🔹 smaller hint text
                          ),
                          filled: true,
                          fillColor: const Color.fromRGBO(217, 217, 217, 0.10),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              "assets/images/Magnifer.png",
                              width: 2, // 🔹 smaller image
                              height: 2,
                              color: Colors.white54,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical:
                                8, // 🔹 ensures text is vertically centered
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 230,
                      child:
                          filteredContacts.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/noContacts.png", // 🔹 your "no contacts" image
                                      width: 90,
                                      height: 90,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "       No contacts yet!\nTime to invite some friends!",
                                      style: GoogleFonts.bricolageGrotesque(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: filteredContacts.length,
                                itemBuilder: (context, index) {
                                  final contact = filteredContacts[index];

                                  return Padding(
                                    // ✅ FIXED: added return
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      minVerticalPadding: 6,
                                      leading: const CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/contactsProfile.png",
                                        ),
                                      ),
                                      title: Text(
                                        contact["name"]!,
                                        style: GoogleFonts.bricolageGrotesque(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        contact["phone"]!,
                                        style: GoogleFonts.bricolageGrotesque(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      trailing:
                                          selectedContacts.contains(
                                                contact["name"],
                                              )
                                              ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              )
                                              : const Icon(
                                                Icons.radio_button_unchecked,
                                                color: Colors.white70,
                                              ),
                                      onTap: () {
                                        setState(() {
                                          if (selectedContacts.contains(
                                            contact["name"],
                                          )) {
                                            selectedContacts.remove(
                                              contact["name"],
                                            ); // unselect
                                          } else {
                                            selectedContacts.add(
                                              contact["name"]!,
                                            ); // select
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0),

              if (selectedContacts.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Invite action would be handled here
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: const RadialGradient(
                        center: Alignment(0.0, -0.8),
                        radius: 1,
                        colors: [Color(0xFFB78EF5), Color(0xFF6F1CEB)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter, // push content up
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                        ), // adjust spacing
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Invite selected",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              "assets/images/maparrrow.png",
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
