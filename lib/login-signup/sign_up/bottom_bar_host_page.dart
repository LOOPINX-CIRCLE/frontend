// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_1/Home_Pages_UI/profile_page.dart';
// import 'package:flutter_application_1/Host_pages_ui/host_page.dart';
// import 'package:flutter_application_1/Wall/wall_page.dart';
// import 'package:flutter_application_1/screens/home/home_screen.dart';
// import 'package:flutter_application_1/screens/notification/notify_screen.dart';
// import 'package:get/get.dart';

// class TicketController extends GetxController {
//   RxBool showBeautyQueen = false.obs;

//   void togglePage() {
//     showBeautyQueen.value = !showBeautyQueen.value;
//   }
// }

import 'package:flutter/material.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';

class BottomBar extends StatefulWidget {
  final int initialIndex;
  const BottomBar({super.key, this.initialIndex = 0});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    HomePages(),
    BookedTicket(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF101010),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'My tickets'),
        ],
      ),
    );
  }
}
// class BottomBar extends StatefulWidget {
//   const BottomBar({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _BottomBarState createState() => _BottomBarState();
// }

// class _BottomBarState extends State<BottomBar> {
//   int _selectedIndex = 0;
//   final TicketController controller = Get.put(
//     TicketController(),
//   ); // ✅ Controller created here

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

//   final List<String> _icons = [
//     'assets/icons/binary/home.png',
//     'assets/icons/binary/wall.png',
//     'assets/icons/binary/subscription.png',
//     'assets/icons/binary/notify.png',
//     'assets/icons/binary/people.png',
//   ];

//   final List<String> _labels = ["Home", "Wall", "Host", "Notify", "Profile"];
//   List<Widget> get _screens => [
//     const HomeScreen(),
//     WallScreen(),
//     HostHomeScreen(),
//     NotificationUI(),
//     ProfilePage(),
//   ];

//   Widget _getBody() => _screens[_selectedIndex];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           _getBody(),
//           Positioned(
//             left: 20,
//             right: 20,
//             bottom: 24, // 👈 move it a little up
//             child: Container(
//               height: 65,
//               width: 345,
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: const Color.fromRGBO(16, 16, 16, 0.80),
//                 borderRadius: BorderRadius.circular(100),
//                 border: Border.all(
//                   color: Color.fromRGBO(255, 255, 255, 0.07), // 👈 stroke
//                   width: 2,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(_icons.length, (index) {
//                   final bool isSelected = _selectedIndex == index;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedIndex = index;
//                       });
//                     },
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
//                                   color: Color.fromRGBO(255, 255, 255, 0.07),
//                                   width: 1.5,
//                                 )
//                                 : null,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.center,
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
