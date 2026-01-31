import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_code/core/services/auth_service.dart';

import 'package:video_player/video_player.dart';
// The screen to navigate to
import 'package:text_code/login-signup/sign_up/mobile_no.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Hide system UI for a full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Fix: Use correct case-sensitive filename (Splash.mp4 not splash.mp4)
    _controller = VideoPlayerController.asset('assets/video/Splash.mp4')
      ..initialize().then((_) {
        // This block of code only runs AFTER the video has finished initializing.

        // Ensure the first frame is shown and trigger a rebuild
        if (mounted) {
          setState(() {});

          // Now, play the video
          _controller.play();

          // And ONLY NOW, start the timer to navigate away.
          _navigateToHome();
        }
      }).catchError((error) {
        // Handle video loading errors - navigate immediately if video fails
        print('Error loading splash video: $error');
        if (mounted) {
          _navigateToHome();
        }
      });

    // Set volume can be done here.
    _controller.setVolume(0.0);
  }

  void _navigateToHome() async {
    // Wait for a duration. 4 seconds should be enough for your video.
    await Future.delayed(const Duration(seconds: 4));

    // Check if the widget is still in the tree before navigating
    if (mounted) {
      await _checkAutoLogin();
    }
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Add a small delay to ensure services are initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (mounted) {
        if (token != null && token.isNotEmpty) {
          // Token exists, go to home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // No token, go to login/signup - use direct navigation since route might not exist
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => MobileNo(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (error) {
      print('Error during auto login check: $error');
      // Fallback navigation on error - always go to mobile number page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MobileNo(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    // Restore system UI when leaving the splash screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match the video's background
      body: Center(
        // We wait for the controller to be initialized before showing the video
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            // While loading, show a loading indicator instead of just black screen
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
      ),
    );
  }
}
