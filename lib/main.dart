import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/UI_Files/choosing_theme.dart';
import 'package:text_code/splashscreen.dart';
import 'package:text_code/profilePage/profile.dart';
import 'package:text_code/profilePage/profile_controller.dart';
import 'package:text_code/waitHomePage/waitHome.dart';


void main() {
  // Only enable DevicePreview in debug mode, not in production
  runApp(DevicePreview(
    enabled: kDebugMode,
    builder: (context) => MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EventController());
    Get.put(HostPagesController());
    Get.put(ProfileController()); // Initialize ProfileController
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('en'), // Force  English
      supportedLocales: [Locale('en')],
      // home: AnalyticsPage(),
      initialRoute: '/',
      defaultTransition: Transition.fadeIn, // Global fade-in transition for all pages
      transitionDuration: const Duration(milliseconds: 300),
      getPages: [

        // GetPage(name: '/', page: () => BottomBar()),
        // GetPage(name: '/choosing_theme', page: () => ChoosingTheme()),

        GetPage(name: '/', page: () => SplashScreen()),
        // GetPage(name: '/home', page: () => BottomBar()),
        // GetPage(name: '/choosing_theme', page: () => ChoosingTheme()),
      ],
    );
  }
}
