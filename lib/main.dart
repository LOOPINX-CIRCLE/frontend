import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/UI_Files/choosing_theme.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (contexr) => MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EventController());
    Get.put(HostPagesController()); // yeh add karo
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('en'), // Force  English
      supportedLocales: [Locale('en')],
      // home: AnalyticsPage(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => BottomBar()),
        GetPage(name: '/choosing_theme', page: () => ChoosingTheme()),
      ],
    );
  }
}
