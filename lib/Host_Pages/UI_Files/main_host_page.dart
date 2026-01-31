import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/UI_Files/choosing_theme.dart';

class MainHostPage extends StatelessWidget {
  const MainHostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // 👈 full screen fill karega
        children: [
          /// 🔹 Full background image
          Image.asset(
            "assets/images/intro page.png",
            fit: BoxFit.cover, // 👈 image stretch karke pura screen fill karegi
          ),

          /// 🔹 Button at bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => ChoosingTheme());
                },
                child: Image.asset(
                  "assets/images/button/Button Active V2.png",
                  height: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
