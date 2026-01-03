

import 'package:flutter/material.dart';
import 'package:text_code/login-signup/sign_up/identity.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/models/event_interest.dart';
import 'package:text_code/core/network/api_exception.dart';

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({super.key});

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  final AuthService _authService = AuthService();
  List<EventInterest> interestList = [];
  final List<int> selectedIds = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEventInterests();
  }

  Future<void> _fetchEventInterests() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final interests = await _authService.fetchEventInterests();
      setState(() {
        interestList = interests;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred';
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load interests. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onNext() {
    // Validation: at least 1 interest required
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 1 interest'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validation: maximum 5 interests allowed
    if (selectedIds.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 interests allowed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userController = Get.find<UserController>();
    // Save event interests to UserController
    userController.setEventInterests(selectedIds);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenderScreen(
          userName: userController.userName.value.isNotEmpty 
              ? userController.userName.value 
              : '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Button is enabled when at least 1 and at most 5 interests are selected
    final bool isValid = selectedIds.isNotEmpty && selectedIds.length <= 5;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👈 Back Button
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/arrowbackbutton.png', // 👈 Replace with your back arrow image
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              /// Title
              Text(
                "Select the experiences that spark your curiosity ",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),

              /// Interests List
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage!,
                                  style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchEventInterests,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : interestList.isEmpty
                            ? Center(
                                child: Text(
                                  'No interests available',
                                  style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: interestList.map((interest) {
                                    final bool isSelected = selectedIds.contains(interest.id);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedIds.remove(interest.id);
                                          } else if (selectedIds.length < 5) {
                                            selectedIds.add(interest.id);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Maximum 5 interests allowed'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : const Color(0xFF1F1F21),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Colors.grey.shade700),
                                        ),
                                        child: Text(
                                          interest.name, // Display only the name field
                                          style: TextStyle(
                                            color: isSelected ? Colors.black : Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'BricolageGrotesque',
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
              ),

              const SizedBox(height: 30),

              /// Continue Button
              // GestureDetector(
              //   onTap: isValid ? _onNext : null,
              //   child: Container(
              //     width: double.infinity,
              //     height: 51,
              //     decoration: BoxDecoration(
              //       gradient: isValid
              //           ? const RadialGradient(
              //               center: Alignment.center,
              //               radius: 3.5,
              //               colors: [
              //                 Color(0xFF555560),
              //                 Color(0xFF1C1C1D),
              //               ],
              //             )
              //           : const LinearGradient(
              //               colors: [
              //                 Color(0xff1F1F21),
              //                 Color(0xff1F1F21),
              //               ],
              //             ),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           "Continue",
              //           style: TextStyle(
              //             fontSize: 18,
              //             fontFamily: 'BricolageGrotesque',
              //             color: isValid ? Colors.white : const Color(0xff868686),
              //           ),
              //         ),
              //         const SizedBox(width: 8),
              //         Image.asset(
              //           "assets/images/right.png", // ✅ Continue icon
              //           height: screenHeight * 0.025,
              //           color: isValid ? Colors.white : const Color(0xff868686),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

//              
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


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

  }
}
