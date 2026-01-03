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
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class EventCheckIn extends StatelessWidget {
  final List<User> users;

  const EventCheckIn({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = List.from(users);

    return StatefulBuilder(
      builder: (context, setState) {
        void filterUsers(String query) {
          setState(() {
            if (query.isEmpty) {
              filteredUsers = List.from(users);
            } else {
              filteredUsers = users
                  .where((user) =>
                      user.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }
          });
        }

        void toggleCheckIn(User user) {
          setState(() {
            final newStatus = !user.isProcessed;
            user.isProcessed = newStatus;
            TabContentUI.updateUserCheckInStatus(user.id, newStatus);
          });
        }

        return Container(
          width: 391,
          height: 690,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
            ),
            gradient: const LinearGradient(
              begin: Alignment(-0.5, -0.9),
              end: Alignment(0.5, 0.9),
              stops: [0.2745, 0.8516],
              colors: [
                Color(0xFF1B1B1B),
                Color(0xFF1B1B1B),
              ],
            ),
          ),
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
                    'Guests',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // USER LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final secretCode = '${1000 + index}${1000 + index}';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage(user.imagePath),
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

                          const SizedBox(height: 6),

                          // SECRET CODE UNDER CHECK-IN BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Secret code:',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFAEAEAE),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),

                                const SizedBox(width: 20),
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9355F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
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
    );
  }
}
