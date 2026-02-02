
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/login-signup/sign_up/dob_page.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:google_fonts/google_fonts.dart';


class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final text = _nameController.text.trim();
      final lettersOnly = text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      setState(() {
        isButtonEnabled = lettersOnly.length >= 2;
      });
    });
  }

  void _onContinue() {
    // Save name to controller
    final userController = Get.put(UserController());
    userController.setUserName(_nameController.text.trim());
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BirthDateScreen(userName: _nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ✅ Background
          Positioned.fill(
                child: Image.asset('assets/images/bg3.png', fit: BoxFit.cover),
              ),
//           SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
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
//                                 const Text(
//                                   'What Should We\nCall You?',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                     fontFamily: 'BricolageGrotesque',
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.2,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Container(
//                                   height: 62,
//                                   width: 311,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF141414),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: TextField(
//                                       controller: _nameController,
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 20,
//                                         fontFamily: 'BricolageGrotesque',
//                                       ),
//                                       decoration: const InputDecoration(
//                                         border: InputBorder.none,
//                                         hintText: 'Your name',
//                                         hintStyle: TextStyle(
//                                           color: Color(0xFF868686),
//                                           fontSize: 20,
//                                           fontFamily: 'BricolageGrotesque',
//                                         ),
//                                       ),
//                                     ),
//                                   ),
                              
//                           // const SizedBox(height: 222),
//                           GestureDetector(
//                             onTap: isButtonEnabled ? _onContinue : null,
//                             child: Container(
//                               width: double.infinity,
//                               height: 51,
//                               decoration: BoxDecoration(
//                                 gradient:
//                                     isButtonEnabled
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
//                                           isButtonEnabled
//                                               ? Colors.white
//                                               : const Color(0xff868686),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Image.asset(
//                                     "assets/images/right.png",
//                                     height: screenHeight * 0.025,
//                                     color:
//                                         isButtonEnabled
//                                             ? Colors.white
//                                             : const Color(0xff868686),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                             ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 40), // bottom padding
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
                left: 24,
                right: 24,
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
                      color: const Color.fromARGB(255, 95, 95, 95),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'What Should We\nCall You?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 62,
                          width: 311,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'BricolageGrotesque',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                  color: Color(0xFF868686),
                                  fontSize: 16,
                                  fontFamily: 'BricolageGrotesque',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isButtonEnabled ? _onContinue : null,
                          child: Container(
                            width: double.infinity,
                            height: 51,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                isButtonEnabled
                                    ? "assets/images/button2.png"   // when enabled
                                    : "assets/images/button1.png", // when disabled
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