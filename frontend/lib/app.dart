import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

class AgriiAIApp extends StatelessWidget {
  const AgriiAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrii AI',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
