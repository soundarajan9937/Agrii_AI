import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AgriAssistApp());
}

class AgriAssistApp extends StatelessWidget {
  const AgriAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ==========================================================
      // APP SETTINGS
      // ==========================================================
      debugShowCheckedModeBanner: false,

      title: 'AgriAssist AI',

      // ==========================================================
      // THEME
      // ==========================================================
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),

        scaffoldBackgroundColor: Colors.white,

        // ========================================================
        // APP BAR
        // ========================================================
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),

        // ========================================================
        // TEXT FIELDS
        // ========================================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
        ),
      ),

      // ==========================================================
      // START SCREEN
      // ==========================================================
      //
      // IMPORTANT:
      // The app starts with SplashScreen.
      //
      // SplashScreen will automatically go to
      // OnboardingScreen after 3 seconds.
      //
      // ==========================================================
      home: const SplashScreen(),
    );
  }
}
