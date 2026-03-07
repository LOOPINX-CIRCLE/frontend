// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:text_code/Reusable/tab_content_ui.dart';

// class EventCheckIn extends StatelessWidget {
//   final List<User> users;

//   const EventCheckIn({
//     super.key,
//     required this.users,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController searchController = TextEditingController();
//     List<User> filteredUsers = List.from(users);

//     return StatefulBuilder(
//       builder: (context, setState) {
//         void filterUsers(String query) {
//           setState(() {
//             if (query.isEmpty) {
//               filteredUsers = List.from(users);
//             } else {
//               filteredUsers = users
//                   .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
//                   .toList();
//             }
//           });
//         }

//         void toggleCheckIn(User user) {
//           setState(() {
//             final newStatus = !user.isProcessed;
//             user.isProcessed = newStatus;
//             // Update check-in status in confirmed users list immediately
//             TabContentUI.updateUserCheckInStatus(user.id, newStatus);
//           });
//         }

//         return Container(
//           width: 391,
//           height: 690,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(40),
//               topRight: Radius.circular(40),
//             ),
//             border: Border(
//               top: BorderSide(
//                 color: Colors.white.withOpacity(0.14),
//                 width: 1,
//               ),
//             ),
//             gradient: const LinearGradient(
//               begin: Alignment(-0.5, -0.9),
//               end: Alignment(0.5, 0.9),
//               stops: [0.2745, 0.8516],
//               colors: [
//                 Color(0xFF1B1B1B),
//                 Color(0xFF1B1B1B),
//               ],
//             ),
//           ),
//           child: Column(
//             children: [
//               // Title
//               Text(
//                 'Guest List',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Search bar
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF171717),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.1),
//                     width: 1,
//                   ),
//                 ),
//                 child: TextField(
//                   controller: searchController,
//                   onChanged: filterUsers,
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontSize: 14,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'Search by name, code',
//                     hintStyle: GoogleFonts.poppins(
//                       color: Colors.grey.withOpacity(0.5),
//                       fontSize: 14,
//                     ),
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Section header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Guests',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               // User list
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredUsers.length,
//                   itemBuilder: (context, index) {
//                     final user = filteredUsers[index];
//                     final secretCode = '${1000 + index}${1000 + index}';
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 24,
//                                 backgroundImage: AssetImage(user.imagePath),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   user.name,
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () => toggleCheckIn(user),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                                   decoration: BoxDecoration(
//                                     color: user.isProcessed
//                                         ? const Color(0xFF4A4A4A)
//                                         : const Color(0xFF9355F0),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     user.isProcessed ? 'Checked In' : 'Check-In',
//                                     style: GoogleFonts.poppins(
//                                       color: user.isProcessed
//                                           ? const Color(0xFFAEAEAE)
//                                           : Colors.white,
//                                       fontSize: user.isProcessed ? 16 : 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           // Secret code below the check-in button - text and code at opposite ends
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Secret code:',
//                                 style: GoogleFonts.poppins(
//                                   color: const Color(0xFFAEAEAE),
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                               ),
//                               Text(
//                                 secretCode,
//                                 style: GoogleFonts.poppins(
//                                   color: const Color(0xFFAEAEAE),
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF9355F0),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Done',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/core/services/invitation_service.dart';
import 'package:text_code/HostManagement/confirmedLoader.dart';
import 'package:text_code/core/utils/image_url_helper.dart';

class EventCheckIn extends StatefulWidget {
  final List<User> users;
  final int? eventId; // Optional: if provided, fetch confirmed users from API

  const EventCheckIn({
    super.key,
    required this.users,
    this.eventId,
  });

  @override
  State<EventCheckIn> createState() => _EventCheckInState();
}

class _EventCheckInState extends State<EventCheckIn> {
  late List<User> confirmedUsers;
  final InvitationService _invitationService = InvitationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    confirmedUsers = List.from(widget.users);
    
    // If eventId is provided, fetch confirmed users from API
    if (widget.eventId != null) {
      _loadConfirmedUsers();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadConfirmedUsers() async {
    try {
      final attendees = await _invitationService.getEventAttendees(widget.eventId!);
      
      setState(() {
        confirmedUsers = attendees.map((attendee) {
          // If user is already checked in from API, sync with TabContentUI
          if (attendee.isCheckedIn) {
            TabContentUI.updateUserCheckInStatus(attendee.userId.toString(), true);
          }
          
          return User(
            id: attendee.userId.toString(),
            name: attendee.fullName,
            imagePath: (attendee.profilePictureUrl != null && attendee.profilePictureUrl!.isNotEmpty)
                ? attendee.profilePictureUrl!
                : 'assets/images/avatar.png',
            isProcessed: attendee.isCheckedIn, // Load checked-in status from API
            ticketSecret: attendee.ticketSecret,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = List.from(confirmedUsers);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) {
            void filterUsers(String query) {
              setState(() {
                if (query.isEmpty) {
                  filteredUsers = List.from(confirmedUsers);
                } else {
                  filteredUsers = confirmedUsers
                      .where((user) =>
                          user.name.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            Future<void> toggleCheckIn(User user) async {
          if (user.ticketSecret == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket secret not available')),
            );
            return;
          }

          try {
            final response = await _invitationService.checkInWithTicketSecret(
              eventId: widget.eventId!,
              ticketSecret: user.ticketSecret!,
            );

            if (response['success'] == true) {
              setState(() {
                user.isProcessed = true;
                TabContentUI.updateUserCheckInStatus(user.id, true);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    response['already_checked_in'] == true
                        ? '${user.name} was already checked in'
                        : '${user.name} checked in successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check-in failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Text(
                'Check-In List',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // If no confirmed users, show empty state
              if (confirmedUsers.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/Check in empty state.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Check-in starts 3hr\nbefore the event',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Guests who check in at your event will appear here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Confirmed guests page
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ConfirmedLoader(
                                  eventId: widget.eventId ?? 0,
                                  isCheckInMode: false,
                                ),
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9355F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View Guest List',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Search Bar
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterUsers,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, code',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'List of guest to check in',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // USER LIST - Use Expanded with ListView inside to fill available space
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final secretCode = user.ticketSecret ?? '${1000 + index}${1000 + index}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1B1B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[700],
                                    backgroundImage: (user.imagePath.startsWith('assets'))
                                        ? AssetImage(user.imagePath) as ImageProvider
                                        : NetworkImage(imageUrl(user.imagePath)),
                                    onBackgroundImageError: (error, stackTrace) {
                                      if (kDebugMode) {
                                        final resolvedUrl = imageUrl(user.imagePath);
                                        print('❌ [IMAGE_LOAD_FAILED] ${user.name}');
                                        print('   Raw imagePath: ${user.imagePath}');
                                        print('   Resolved URL: $resolvedUrl');
                                        print('   Error: $error');
                                        print('   Error Type: ${error.runtimeType}');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => toggleCheckIn(user),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: user.isProcessed
                                            ? const Color(0xFF4A4A4A)
                                            : const Color(0xFF9355F0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        user.isProcessed
                                            ? 'Checked In'
                                            : 'Check-In',
                                        style: GoogleFonts.poppins(
                                          color: user.isProcessed
                                              ? const Color(0xFFAEAEAE)
                                              : Colors.white,
                                          fontSize: user.isProcessed ? 16 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // SECRET CODE UNDER CHECK-IN BUTTON
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Secret code',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFAEAEAE),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    secretCode,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFAEAEAE),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9355F0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      confirmedUsers.isEmpty ? 'Back' : 'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
        ),
      ),
    );
  }
}
