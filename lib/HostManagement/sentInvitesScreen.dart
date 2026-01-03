// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:text_code/Reusable/tab_content_ui.dart';
// import 'package:text_code/HostManagement/eventInvited.dart';

// class SentInvitesScreen extends StatefulWidget {
//   final String eventName;
//   final String eventPrice;
//   final int confirmedUsers;

//   const SentInvitesScreen({
//     super.key,
//     required this.eventName,
//     required this.eventPrice,
//     required this.confirmedUsers,
//   });

//   @override
//   State<SentInvitesScreen> createState() => _SentInvitesScreenState();
// }

// class _SentInvitesScreenState extends State<SentInvitesScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<User> _users = [];
//   List<User> _filteredUsers = [];
//   bool _selectAll = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with 10 users
//     _users = [
//       User(id: '1', name: 'Clara', imagePath: 'assets/images/avatar.png'),
//       User(id: '2', name: 'Muskan', imagePath: 'assets/images/avatar.png'),
//       User(id: '3', name: 'Anshi', imagePath: 'assets/images/avatar.png'),
//       User(id: '4', name: 'Sanjana mall', imagePath: 'assets/images/avatar.png'),
//       User(id: '5', name: 'Anushka', imagePath: 'assets/images/avatar.png'),
//       User(id: '6', name: 'Priya', imagePath: 'assets/images/avatar.png'),
//       User(id: '7', name: 'Riya', imagePath: 'assets/images/avatar.png'),
//       User(id: '8', name: 'Sneha', imagePath: 'assets/images/avatar.png'),
//       User(id: '9', name: 'Kavya', imagePath: 'assets/images/avatar.png'),
//       User(id: '10', name: 'Meera', imagePath: 'assets/images/avatar.png'),
//     ];
//     _filteredUsers = List.from(_users);
//     _searchController.addListener(_filterUsers);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _filterUsers() {
//     setState(() {
//       if (_searchController.text.isEmpty) {
//         _filteredUsers = List.from(_users);
//       } else {
//         _filteredUsers = _users
//             .where((user) => user.name
//                 .toLowerCase()
//                 .contains(_searchController.text.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void _toggleSelectAll() {
//     setState(() {
//       _selectAll = !_selectAll;
//       for (var user in _filteredUsers) {
//         user.isSelected = _selectAll;
//       }
//     });
//   }

//   void _toggleUserSelection(User user) {
//     setState(() {
//       user.isSelected = !user.isSelected;
//       _selectAll = _filteredUsers.every((u) => u.isSelected);
//     });
//   }

//   void _sendSelectedUsers() {
//     // Get selected users and convert to tab_content_ui User format
//     final selectedUsers = _filteredUsers
//         .where((u) => u.isSelected)
//         .map((u) => User(
//               id: u.id,
//               name: u.name,
//               imagePath: u.imagePath,
//               isSelected: u.isSelected,
//               isProcessed: true, // Mark as invited
//             ))
//         .toList();
    
//     if (selectedUsers.isNotEmpty) {
//       // Get the root navigator context before closing
//       final rootContext = Navigator.of(context, rootNavigator: true).context;
//       // Close current screen
//       Navigator.pop(context);
//       // Show eventInvited with selected users after a delay
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (rootContext.mounted) {
//           showModalBottomSheet(
//             context: rootContext,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => EventInvited(users: selectedUsers),
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF101010),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 56),
//             child: Column(
//               children: [
//                 // Top row with back button and event info
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: const BoxDecoration(
//                             color: Color(0xFF2C2C2E),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Image.asset(
//                               'assets/images/arrowbackbutton.png',
//                               width: 24,
//                               height: 24,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color(0x1A000000),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: const Color(0x802B2B2B),
//                                 width: 2,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   widget.eventName,
//                                   style: GoogleFonts.bricolageGrotesque(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   widget.eventPrice,
//                                   style: GoogleFonts.bricolageGrotesque(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Capacity indicator
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E1C1C),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           'assets/images/shinypurple.png',
//                           width: 16,
//                           height: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Capacity ${widget.confirmedUsers} / 200 Accepted',
//                           style: GoogleFonts.poppins(
//                             color: const Color(0xFFAEAEAE),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Title
//                 Text(
//                   'Sent Invites',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Search bar
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF171717),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.1),
//                         width: 1,
//                       ),
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: 'Search by name',
//                         hintStyle: GoogleFonts.poppins(
//                           color: Colors.grey.withOpacity(0.5),
//                           fontSize: 14,
//                         ),
//                         border: InputBorder.none,
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Section header with Select All
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Exclusive users',
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: _toggleSelectAll,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF171717),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.1),
//                               width: 1,
//                             ),
//                           ),
//                           child: Text(
//                             _selectAll ? 'Deselect All' : 'Select All',
//                             style: GoogleFonts.poppins(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // User list
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     children: _filteredUsers.map((user) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundImage: AssetImage(user.imagePath),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 user.name,
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () => _toggleUserSelection(user),
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: user.isSelected ? 16 : 24,
//                                   vertical: user.isSelected ? 6 : 10,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: user.isSelected
//                                       ? const Color(0xFF4A4A4A)
//                                       : const Color(0xFF9355F0),
//                                   borderRadius: BorderRadius.circular(
//                                     user.isSelected ? 29 : 20,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   user.isSelected ? 'Selected' : 'Invite',
//                                   style: GoogleFonts.poppins(
//                                     color: user.isSelected
//                                         ? const Color(0xFFAEAEAE)
//                                         : Colors.white,
//                                     fontSize: user.isSelected ? 16 : 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 // Selected users container and Invite button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       if (_filteredUsers.where((u) => u.isSelected).isNotEmpty) ...[
//                         Container(
//                           width: 280,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF9355F0),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             children: [
//                               Image.asset(
//                                 'assets/icons/Users Group Two Rounded.png',
//                                 width: 24,
//                                 height: 24,
//                                 color: Colors.white,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   '${_filteredUsers.where((u) => u.isSelected).take(3).map((u) => u.name).join(",")}'
//                                   '${_filteredUsers.where((u) => u.isSelected).length > 3 ? ", +${_filteredUsers.where((u) => u.isSelected).length - 3}" : ""}',
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         GestureDetector(
//                           onTap: _sendSelectedUsers,
//                           child: Image.asset(
//                             'assets/icons/Invite user.png',
//                             width: 40,
//                             height: 40,
//                           ),
//                         ),
//                       ] else ...[
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF9355F0),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Done',
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// Updated Flutter UI Code with required changes
// - Removed UI above capacity section
// - Rounded top corners of full screen container
// - Fixed Done button at bottom (static)
// - User list is scrollable
// - Logic untouched

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/HostManagement/eventInvited.dart';

class SentInvitesScreen extends StatefulWidget {
  final String eventName;
  final String eventPrice;
  final int confirmedUsers;
  final VoidCallback? onUsersInvited;

  const SentInvitesScreen({
    super.key,
    required this.eventName,
    required this.eventPrice,
    required this.confirmedUsers,
    this.onUsersInvited,
  });

  @override
  State<SentInvitesScreen> createState() => _SentInvitesScreenState();
}

class _SentInvitesScreenState extends State<SentInvitesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    final allUsers = [
      User(id: '1', name: 'Clara', imagePath: 'assets/images/avatar.png'),
      User(id: '2', name: 'Muskan', imagePath: 'assets/images/avatar.png'),
      User(id: '3', name: 'Anshi', imagePath: 'assets/images/avatar.png'),
      User(id: '4', name: 'Sanjana mall', imagePath: 'assets/images/avatar.png'),
      User(id: '5', name: 'Anushka', imagePath: 'assets/images/avatar.png'),
      User(id: '6', name: 'Priya', imagePath: 'assets/images/avatar.png'),
      User(id: '7', name: 'Riya', imagePath: 'assets/images/avatar.png'),
      User(id: '8', name: 'Sneha', imagePath: 'assets/images/avatar.png'),
      User(id: '9', name: 'Kavya', imagePath: 'assets/images/avatar.png'),
      User(id: '10', name: 'Meera', imagePath: 'assets/images/avatar.png'),
    ];
    
    // Filter out already invited users
    _users = allUsers.where((user) => !TabContentUI.isUserInvited(user.id)).toList();
    _filteredUsers = List.from(_users);
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users
            .where((u) => u.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (var user in _filteredUsers) {
        user.isSelected = _selectAll;
      }
    });
  }

  void _toggleUserSelection(User user) {
    setState(() {
      user.isSelected = !user.isSelected;
      _selectAll = _filteredUsers.every((u) => u.isSelected);
    });
  }

  void _sendSelectedUsers() {
    final selectedUsers = _filteredUsers
        .where((u) => u.isSelected)
        .map((u) => User(
              id: u.id,
              name: u.name,
              imagePath: u.imagePath,
              isSelected: false, // Reset selection state
              isProcessed: true, // Mark as invited
            ))
        .toList();

    if (selectedUsers.isNotEmpty) {
      // Save invited users to TabContentUI (appends to existing list)
      TabContentUI.addInvitedUsers(selectedUsers);
      
      // Remove invited users from the current list
      final selectedIds = selectedUsers.map((u) => u.id).toSet();
      _users.removeWhere((user) => selectedIds.contains(user.id));
      _filteredUsers.removeWhere((user) => selectedIds.contains(user.id));
      
      // Reset select all state
      _selectAll = false;
      
      // Update UI
      setState(() {});
      
      // Notify parent to refresh count
      if (widget.onUsersInvited != null) {
        widget.onUsersInvited!();
      }
      
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (rootContext.mounted) {
          showModalBottomSheet(
            context: rootContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EventInvited(users: selectedUsers),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                // Title
                Text(
                  'Sent Invites',
            textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // Search bar
          Container(
            width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name',
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
          // Exclusive users header with Select All
          Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exclusive users',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleSelectAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171717),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                    _selectAll ? 'Deselect All' : 'Select All',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                ),
                const SizedBox(height: 16),
          // User List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
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
                              onTap: () => _toggleUserSelection(user),
                              child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: user.isSelected ? 16 : 24,
                            vertical: user.isSelected ? 6 : 10,
                          ),
                                decoration: BoxDecoration(
                            color: user.isSelected
                                ? const Color(0xFF4A4A4A)
                                : const Color(0xFF9355F0),
                            borderRadius: BorderRadius.circular(
                              user.isSelected ? 29 : 20,
                            ),
                                ),
                                child: Text(
                            user.isSelected ? 'Selected' : 'Invite',
                                  style: GoogleFonts.poppins(
                              color: user.isSelected
                                  ? const Color(0xFFAEAEAE)
                                  : Colors.white,
                              fontSize: user.isSelected ? 16 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ),
          // Divider line
          Container(
                      width: double.infinity,
            height: 1,
            color: const Color(0xFF333333),
          ),
          const SizedBox(height: 25),
          // Bottom button section
          if (_filteredUsers.where((u) => u.isSelected).isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9355F0),
                        borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/Users Group Two Rounded.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_filteredUsers.where((u) => u.isSelected).take(3).map((u) => u.name).join(",")}'
                          '${_filteredUsers.where((u) => u.isSelected).length > 3 ? ", +${_filteredUsers.where((u) => u.isSelected).length - 3}" : ""}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendSelectedUsers,
                  child: Image.asset(
                    'assets/icons/Invite user.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ] else ...[
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9355F0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
                const SizedBox(height: 20),
              ],
      ),
    );
  }
}
