// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class WaitlistScreen extends StatefulWidget {
//   const WaitlistScreen({super.key});

//   @override
//   State<WaitlistScreen> createState() => _WaitlistScreenState();
// }

// class _WaitlistScreenState extends State<WaitlistScreen> {
//   final bool isLocked = true;
//   int _selectedIndex = 0;

//   final List<String> _icons = [
//     'assets/icons/binary/home.png',
//     'assets/icons/binary/wall.png',
//     'assets/icons/binary/notify.png',
//     'assets/icons/binary/subscription.png',
//     'assets/icons/binary/people.png',
//   ];

//   final List<String> _labels = ["Home", "Wall", "Notify", "Host", "Profile"];

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff101010),
//       body: Stack(
//         children: [
//           /// 🎞️ Center GIF
//           Center(
//             child: Image.asset(
//               'assets/images/waitlist.gif',
//               width: 451,
//               height: 398,
//               fit: BoxFit.contain,
//             ),
//           ),

//           /// ⬇️ Custom bottom nav (Home selected, all disabled)
//           Positioned(
//             left: 20,
//             right: 20,
//             bottom: 50,
//             child: Container(
//               height: 65,
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: const Color.fromRGBO(16, 16, 16, 0.8),
//                 borderRadius: BorderRadius.circular(100),
//                 border: Border.all(
//                   color: const Color.fromRGBO(255, 255, 255, 0.07),
//                   width: 2,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(_icons.length, (index) {
//                   final bool isSelected = _selectedIndex == index;

//                   return IgnorePointer(
//                     ignoring: isLocked, // disables all taps
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSelected ? 12 : 0,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(30),
//                         border:
//                             isSelected
//                                 ? Border.all(
//                                   color: const Color.fromRGBO(
//                                     255,
//                                     255,
//                                     255,
//                                     0.07,
//                                   ),
//                                   width: 1.5,
//                                 )
//                                 : null,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Image.asset(
//                             _icons[index],
//                             width: 24,
//                             height: 24,
//                             color: Colors.white,
//                           ),
//                           if (isSelected)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 6.0),
//                               child: Text(
//                                 _labels[index],
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                   fontFamily: "BricolageGrotesque",
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
