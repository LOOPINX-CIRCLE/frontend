// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:text_code/Home_pages/UI_Design/home_with_tabs.dart';
import 'package:text_code/Host_Pages/UI_Files/main_host_page.dart';
import 'package:text_code/profilePage/profile.dart';

class TicketController extends GetxController {
  RxBool showBeautyQueen = false.obs;
  void togglePage() {
    showBeautyQueen.value = !showBeautyQueen.value;
  }
}

class BottomBar extends StatefulWidget {
  final int initialIndex;
  const BottomBar({super.key, this.initialIndex = 0});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  final TicketController controller = Get.put(
    TicketController(),
  ); // ✅ Controller created here

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _selectedIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // Bottom bar items: Home, Host, Profile (Discover tab removed)
  final List<String> _icons = [
    'assets/icons/Homes.png',        // Home
    'assets/icons/Crown Line.png',   // Host
    "assets/icons/User.png",         // Profile
  ];

  final List<String> _labels = ["Home", "Host", "Profile"];

  List<Widget> get _screens => [
    const HomeWithTabs(initialTab: 0),          // Home
    MainHostPage(),                             // Host
    ProfilePage(hasHomePagesAccess: true),      // Profile
  ];

  Widget _getBody() => _screens[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _getBody(),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24, // 👈 move it a little up
            child: Container(
              height: 65,
               width: 225,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(16, 16, 16, 0.80),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.07), // 👈 stroke
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_icons.length, (index) {
                  final bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 12 : 0,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: isSelected
                            ? Border.all(
                                color: Color.fromRGBO(255, 255, 255, 0.07),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            _icons[index],
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                _labels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "BricolageGrotesque",
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
