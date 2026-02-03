
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/UI_Files/choosing_theme.dart';
import 'package:text_code/core/constants/env.dart';
import 'package:text_code/splashscreen.dart';
// import 'package:text_code/simple_splash.dart';
// import 'package:text_code/improved_splash.dart';
// import 'package:text_code/simple_splash.dart';
// import 'package:text_code/profilePage/profile.dart';
import 'package:text_code/profilePage/profile_controller.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load();
    // Debug print to confirm API key loaded
    if (kDebugMode) {
      print('🔍 GOOGLE_MAPS_API_KEY from .env: "${dotenv.env['GOOGLE_MAPS_API_KEY']}"');
      print('🔍 Env.googleMapsApiKey: "${Env.googleMapsApiKey}"');
      print('🔍 API key length: ${Env.googleMapsApiKey.length}');
      print('🔍 API key empty? ${Env.googleMapsApiKey.isEmpty}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Warning: Could not load .env file: $e');
    }
  }
  
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
      locale: DevicePreview.locale(context) ?? const Locale('en'), // Handle DevicePreview
      builder: DevicePreview.appBuilder,
      supportedLocales: const [Locale('en')],
      // home: AnalyticsPage(),
      initialRoute: '/',
      defaultTransition: Transition.fadeIn, // Global fade-in transition for all pages
      transitionDuration: const Duration(milliseconds: 300),
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/choosing_theme', page: () => ChoosingTheme()),
        GetPage(name: '/home', page: () => BottomBar()),
      ],
    );
  }
}
