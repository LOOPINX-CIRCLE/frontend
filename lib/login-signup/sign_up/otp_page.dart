
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_code/login-signup/sign_up/name_page.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/network/api_exception.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OTPPage({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isOtpComplete = false;
  bool _isResending = false;

  Future<void> _verifyOTP() async {
    if (_isLoading || !_isOtpComplete) return;

    final otp = _pinController.text.trim();
    if (otp.length != 4) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call verify OTP API
      // Note: countryCode here should be the phone code, but we're storing it correctly from mobile_no.dart
      final response = await _authService.verifyOTP(
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode, // This is now the phone code (e.g., "91")
        otp: otp,
      );

      if (!mounted) return;

      // Check if verification was successful
      if (response['success'] == true && response['token'] != null) {
        // Token is automatically stored by AuthService.verifyOTP()
        // Navigate to name page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NameInputScreen()),
        );
      } else {
        // Handle failure case
        final errorMessage = response['message']?.toString() ?? 'OTP verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Clear OTP field on error
        _pinController.clear();
        setState(() {
          _isOtpComplete = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Clear OTP field on error
      _pinController.clear();
      setState(() {
        _isOtpComplete = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      // Show generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Clear OTP field on error
      _pinController.clear();
      setState(() {
        _isOtpComplete = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Call send OTP API again
      await _authService.sendOTP(
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear OTP field
      _pinController.clear();
      setState(() {
        _isOtpComplete = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/otpPage.png', fit: BoxFit.cover),
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
                  _buildGlassmorphismCard(context),
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

  Widget _buildGlassmorphismCard(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Color(0xff141414),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        color: Color.fromARGB(255, 235, 233, 233),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 343,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 343,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'Almost in verify your Spot',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.normal,
                    //     height: 1.3,
                    //     fontFamily: "bricolageGrotesque",
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    // Pinput OTP Field using the new themes
                    Pinput(
                      length: 4,
                      controller: _pinController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      onCompleted: (pin) {
                        setState(() {
                          _isOtpComplete = true;
                        });
                      },
                      onChanged: (value) {
                        if (value.length < 4 && _isOtpComplete) {
                          setState(() {
                            _isOtpComplete = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildContinueButton(_isOtpComplete), // Moved inside here
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isResending ? null : _resendOTP,
                      child: Text(
                        _isResending ? 'Resending...' : 'Resend OTP',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.48,
                          color: _isResending ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //   Widget _buildContinueButton(bool isActive) {
  //     final Color activeBackgroundColor = Color.fromARGB(255, 57, 56, 57);
  //     final Color inactiveBackgroundColor = Color(0xFF2C2C2E);
  //     final Color activeTextColor = Colors.white;
  //     final Color inactiveTextColor = Colors.grey[600]!;

  //     return GestureDetector(
  //       onTap: () {
  //         _verifyOTP();
  //       },
  //       child: Container(
  //         width: 343,
  //         height: 51,
  //         decoration: BoxDecoration(
  //           gradient: _isOtpComplete
  //               ? const RadialGradient(
  //                   center: Alignment.center,
  //                   radius: 3.5,
  //                   colors: [Color(0xFF555560), Color(0xFF1C1C1D)],
  //                 )
  //               : const LinearGradient(
  //                   colors: [Color(0xff1F1F21), Color(0xff1F1F21)],
  //                 ),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 "Continue",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontFamily: 'BricolageGrotesque',
  //                   color: _isOtpComplete ? Colors.white : Color(0xff868686),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Image.asset(
  //                 "assets/images/right.png",
  //                 color: _isOtpComplete ? Colors.white : Color(0xff868686),
  //                 height: MediaQuery.of(context).size.height * 0.025,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  //   Widget _buildContinueButton(bool isActive) {
  //     return GestureDetector(
  //       onTap: () {
  //         if (_isOtpComplete) {
  //           _verifyOTP();
  //         }
  //       },
  //       child: Container(
  //         width: 343,
  //         height: 51,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           gradient: const LinearGradient(
  //             begin: Alignment.bottomCenter,
  //             end: Alignment.topCenter,
  //             colors: [
  //               Color.fromARGB(77, 241, 234, 234), // 30% opacity white (0x4D = 77)
  //               Colors.black,
  //             ],
  //           ),
  //         ),
  //         child: Container(
  //           height: 51/8,
  //           decoration: const BoxDecoration(
  //             borderRadius: BorderRadius.all(Radius.circular(10)),
  //             gradient: LinearGradient(
  //               begin: Alignment.centerLeft,
  //               end: Alignment.centerRight,
  //               colors: [
  //                 Colors.black,
  //                 Color(0x00000000), // transparent
  //                 Colors.black,
  //               ],
  //             ),
  //           ),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(
  //                 color: const Color(0x4DFFFFFF), // 30% white
  //                 width: 0.5,
  //               ),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             child: Opacity(
  //               opacity: _isOtpComplete ? 1.0 : 0.5,
  //               child: Center(
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       "Continue",
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontFamily: 'BricolageGrotesque',
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Image.asset(
  //                       "assets/images/right.png",
  //                       color: Colors.white,
  //                       height: MediaQuery.of(context).size.height * 0.025,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
  Widget _buildContinueButton(bool isActive) {
    return GestureDetector(
      onTap: () {
        if (_isOtpComplete && !_isLoading) {
          _verifyOTP();
        }
      },
      child: Container(
        width: 343,
        height: 51,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _isLoading
              ? Container(
                  color: const Color(0xFF1F1F21),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Image.asset(
            _isOtpComplete
                ? "assets/images/button2.png" // image when OTP complete
                : "assets/images/button1.png", // image when OTP incomplete
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
