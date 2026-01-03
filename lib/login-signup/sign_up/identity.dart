import 'package:flutter/material.dart';
import 'package:text_code/login-signup/sign_up/file_upload.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:get/get.dart';

class GenderScreen extends StatefulWidget {
  final String userName;

  const GenderScreen({super.key, required this.userName});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  void _onNext() {
    if (selectedGender != null) {
      // Save gender to UserController
      final userController = Get.find<UserController>();
      userController.setGender(selectedGender!);
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhotoUploadScreen()),
      );
    }
  }

  Widget genderButton(String label) {
    final bool isSelected = selectedGender == label;

    return GestureDetector(
      onTap: () => setState(() => selectedGender = label),
      child: Container(
        height: 51,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonEnabled = selectedGender != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/genderbg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Text section on top
         

          // Bottom container (card style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How should we address you?',
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This helps us create a comfortable\nspace for everyone',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  genderButton("Male"),
                  genderButton("Female"),
                  genderButton("Others"),
                  const SizedBox(height: 20),

                  // Continue Button
                  GestureDetector(
                        onTap: buttonEnabled ? _onNext : null,
                        child: Container(
                          width: double.infinity,
                          height: 51,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              buttonEnabled
                                  ? "assets/images/button2.png"
                                  : "assets/images/button1.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
