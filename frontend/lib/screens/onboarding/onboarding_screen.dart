import 'package:flutter/material.dart';
import '../login/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Modern organic green color from your branding
  static const Color agriGreen = Color(0xFF2E7D32);

  // ==========================================================
  // GET STARTED
  // ==========================================================

  void _getStarted(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(initialLoginType: 'User'),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ==================================================
          // FULL SCREEN BACKGROUND IMAGE
          // ==================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/agriassist_ai_phone_wallpaper_1080x1920.png',
              // Fill the COMPLETE phone screen as per image design
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE8F5E9), Colors.white],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.agriculture,
                      size: 80,
                      color: agriGreen,
                    ),
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // GET STARTED BUTTON AREA
          // Placed at the bottom to allow interaction
          // ==================================================
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Functional "GET STARTED" button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () => _getStarted(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: agriGreen,
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 22),
                        ],
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
