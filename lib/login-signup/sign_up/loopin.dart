// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/screens/sign_up/file_upload.dart';


// class InvitationPreferencesScreen extends StatefulWidget {
//   const InvitationPreferencesScreen({super.key});

//   @override
//   State<InvitationPreferencesScreen> createState() =>
//       _InvitationPreferencesScreenState();
// }

// class _InvitationPreferencesScreenState
//     extends State<InvitationPreferencesScreen> {
//   final Set<String> _selectedInterests = {};
//   final int _maxSelections = 5;

//   // Add this list or import from your interest_model.dart if already defined there
//   final List<InterestModel> allInterests = [
//     InterestModel(imageName: 'music'),
//     InterestModel(imageName: 'sports'),
//     InterestModel(imageName: 'art'),
//     InterestModel(imageName: 'travel'),
//     InterestModel(imageName: 'food'),
//     // Add more interests as needed
//   ];

//   void _toggleInterest(String interestName) {
//     setState(() {
//       if (_selectedInterests.contains(interestName)) {
//         _selectedInterests.remove(interestName);
//       } else {
//         if (_selectedInterests.length < _maxSelections) {
//           _selectedInterests.add(interestName);
//         } else {
//           ScaffoldMessenger.of(context).removeCurrentSnackBar();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: const Color.fromARGB(255, 43, 35, 35),
//               content: Text(
//                 'You can select a maximum of $_maxSelections preferences.',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         // 1. Use a Stack to layer the button on top of the content.
//         child: Stack(
//           children: [
//             // 2. The CustomScrollView now takes up the full space.
//             //    We add padding at the bottom to ensure the content doesn't
//             //    get hidden behind the button.
//             CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Select Your Invitation Preferences',
//                           style: TextStyle(
//                             fontFamily: 'BricolageGrotesqueRegular',
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Max: $_maxSelections',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[400],
//                             fontFamily: 'PoppinsRegular',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   sliver: SliverGrid(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           childAspectRatio: 0.7,
//                           crossAxisSpacing: 20,
//                           mainAxisSpacing: 20,
//                         ),
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       final interest = allInterests[index];
//                       final isSelected = _selectedInterests.contains(
//                         interest.imageName,
//                       );
//                       final double tiltDegrees = index.isEven ? -4.0 : 4.0;
//                       final double tiltRadians = tiltDegrees * (pi / 180);

//                       return InterestCard(
//                         interestName: interest.imageName,
//                         isSelected: isSelected,
//                         tiltAngle: tiltRadians,
//                         onTap: () => _toggleInterest(interest.imageName),
//                       );
//                     }, childCount: allInterests.length),
//                   ),
//                 ),
//                 // 3. IMPORTANT: Add padding at the bottom of the scroll view.
//                 //    The height should be enough for the button + its padding.
//                 //    (51px button height + 40px vertical padding = ~91px, let's use 120 for safety).
//                 const SliverToBoxAdapter(child: SizedBox(height: 120)),
//               ],
//             ),

//             // 4. The button is placed at the bottom of the Stack.
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: _buildSaveButton(), // Your existing button builder method
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     final bool isEnabled = _selectedInterests.isNotEmpty;

//     const buttonContent = Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Save',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         SizedBox(width: 8),
//         Icon(Icons.arrow_forward),
//       ],
//     );

//     return Container(
//       color: Colors.black,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           padding: EdgeInsets.zero,
//           minimumSize: const Size(343, 51),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         onPressed: isEnabled
//             ? () {
//                 debugPrint('Selected Interests: $_selectedInterests');
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const PhotoUploadScreen(),
//                   ),
//                 );
//               }
//             : null,
//         child: Ink(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             gradient: isEnabled
//                 ? const RadialGradient(
//                     center: Alignment.center,
//                     radius: 2.0,
//                     colors: [Color(0xFF555560), Color(0xFF1C1C1D)],
//                   )
//                 : null,
//             color: isEnabled ? null : const Color(0xFF2C2C2E),
//           ),
//           child: Container(
//             alignment: Alignment.center,
//             constraints: const BoxConstraints(minWidth: 343, minHeight: 51),
//             child: Opacity(
//               opacity: isEnabled ? 1.0 : 0.5,
//               child: buttonContent,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class InterestCard extends StatelessWidget {
//   final String interestName;
//   final bool isSelected;
//   final double tiltAngle;
//   final VoidCallback onTap;

//   const InterestCard({
//     super.key,
//     required this.interestName,
//     required this.isSelected,
//     required this.tiltAngle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final String imagePath = isSelected
//         ? 'assets/images/$interestName.png'
//         : 'assets/images/${interestName}_bw.png';

//     return GestureDetector(
//       onTap: onTap,
//       child: Transform.rotate(
//         angle: tiltAngle,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               return FadeTransition(opacity: animation, child: child);
//             },
//             child: ClipRRect(
//               key: ValueKey<String>(imagePath),
//               borderRadius: BorderRadius.circular(12.0),
//               child: Image.asset(
//                 imagePath,
//                 fit:
//                     BoxFit.contain, // Changed back to cover for best appearance
//                 width: double.infinity,
//                 height: double.infinity,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[850],
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     alignment: Alignment.center,
//                     child: Icon(Icons.broken_image, color: Colors.grey[600]),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }