import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_code/login-signup/sign_up/vibe_selection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:get/get.dart';

class BirthDateScreen extends StatefulWidget {
  final String userName;
  const BirthDateScreen({super.key, required this.userName});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  final TextEditingController _dateController = TextEditingController();
  final _dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _dateController.addListener(_validateDate);
  }

  void _validateDate() {
    final text = _dateController.text.trim();
    if (_dateRegex.hasMatch(text)) {
      try {
        final parts = text.split('/');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final birthDate = DateTime(year, month, day);
        final now = DateTime.now();

        int age = now.year - year;
        if (now.month < month || (now.month == month && now.day < day)) {
          age--;
        }

        setState(() => isValid = age >= 18 && age <= 100);
        return;
      } catch (_) {}
    }
    setState(() => isValid = false);
  }

  void _onNext() {
    // Save birth date to UserController
    final userController = Get.find<UserController>();
    userController.setBirthDate(_dateController.text.trim());
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InterestSelectionPage(),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;
    final bottomInset = media.viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg4.png', fit: BoxFit.cover),
          ),
          //           SafeArea(
          //             child: LayoutBuilder(
          //               builder: (context, constraints) {
          //                 return SingleChildScrollView(
          //                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          //                   physics: const BouncingScrollPhysics(),
          //                   child: ConstrainedBox(
          //                     constraints: BoxConstraints(
          //                       minHeight: constraints.maxHeight,
          //                     ),
          //                     child: IntrinsicHeight(
          //                       child: Column(
          //                         children: [
          //                           Spacer(),
          //                           Container(
          //                             width: 343,
          //                             padding: const EdgeInsets.all(16),
          //                             decoration: BoxDecoration(
          //                               color: const Color(0xB21F1F1F),
          //                               borderRadius: BorderRadius.circular(10),
          //                             ),
          //                             child: Column(
          //                               children: [
          //                                 Text(
          //                                   'Tell Us Your Birthday',
          //                                   textAlign: TextAlign.center,
          //                                   style: TextStyle(
          //                                     color: Colors.white,
          //                                     fontSize: 22,
          //                                     fontFamily: 'BricolageGrotesque',
          //                                     fontWeight: FontWeight.w400,
          //                                   ),
          //                                 ),
          //                                 const SizedBox(height: 16),
          //                                 Container(
          //                                   width: 311,
          //                                   height: 62,
          //                                   decoration: BoxDecoration(
          //                                     color: const Color(0xFF141414),
          //                                     borderRadius: BorderRadius.circular(10),
          //                                   ),
          //                                   padding: const EdgeInsets.symmetric(
          //                                     horizontal: 16,
          //                                   ),
          //                                   alignment: Alignment.center,
          //                                   child: TextField(
          //                                     controller: _dateController,
          //                                     keyboardType: TextInputType.number,
          //                                     inputFormatters: [
          //                                       FilteringTextInputFormatter.digitsOnly,
          //                                       LengthLimitingTextInputFormatter(8),
          //                                       DateInputFormatter(),
          //                                     ],
          //                                     textAlign: TextAlign.center,
          //                                     style: TextStyle(
          //                                       color: Colors.white,
          //                                       fontSize: 20,
          //                                       fontFamily: 'BricolageGrotesque',
          //                                     ),
          //                                     decoration: const InputDecoration(
          //                                       hintText: '00/00/0000',
          //                                       hintStyle: TextStyle(
          //                                         color: Color(0xFF868686),
          //                                         fontSize: 20,
          //                                         fontFamily: 'BricolageGrotesque',
          //                                       ),
          //                                       border: InputBorder.none,
          //                                     ),
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           const SizedBox(height: 222),
          //                           GestureDetector(
          //                             onTap: isValid ? _onNext : null,
          //                             child: Container(
          //                               width: double.infinity,
          //                               height: 51,
          //                               decoration: BoxDecoration(
          //                                 gradient:
          //                                     isValid
          //                                         ? const RadialGradient(
          //                                           center: Alignment.center,
          //                                           radius: 3.5,
          //                                           colors: [
          //                                             Color(0xFF555560),
          //                                             Color(0xFF1C1C1D),
          //                                           ],
          //                                         )
          //                                         : const LinearGradient(
          //                                           colors: [
          //                                             Color(0xff1F1F21),
          //                                             Color(0xff1F1F21),
          //                                           ],
          //                                         ),
          //                                 borderRadius: BorderRadius.circular(10),
          //                               ),
          //                               child: Row(
          //                                 mainAxisAlignment: MainAxisAlignment.center,
          //                                 children: [
          //                                   Text(
          //                                     "Continue",
          //                                     style: TextStyle(
          //                                       fontSize: 18,
          //                                       fontFamily: 'BricolageGrotesque',
          //                                       color:
          //                                           isValid
          //                                               ? Colors.white
          //                                               : const Color(0xff868686),
          //                                     ),
          //                                   ),
          //                                   const SizedBox(width: 8),
          //                                   Image.asset(
          //                                     "assets/images/right.png",
          //                                     height: screenHeight * 0.025,
          //                                     color:
          //                                         isValid
          //                                             ? Colors.white
          //                                             : const Color(0xff868686),
          //                                   ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                           const SizedBox(height: 40),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }
          // }
          SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              curve: Curves.easeOut,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 343,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 208, 207, 207).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'When Do You Celebrate?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 311,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _dateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                              DateInputFormatter(),
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'BricolageGrotesque',
                            ),
                            decoration: const InputDecoration(
                              hintText: 'DD/MM/YYYY',
                              hintStyle: TextStyle(
                                color: Color(0xFF868686),
                                fontSize: 20,
                                fontFamily: 'BricolageGrotesque',
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isValid ? _onNext : null,
                          child: Container(
                            width: double.infinity,
                            height: 51,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                isValid
                                    ? "assets/images/button2.png"    // Image for enabled state
                                    : "assets/images/button1.png",  // Image for disabled state
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
                              
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);
      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
