import 'package:flutter/material.dart';

import 'package:frontend/screens/chatbot/chatbot_screen.dart';
import 'package:frontend/screens/crop_advisor/crop_advisor_screen.dart';
import 'package:frontend/screens/marketplace/farmer_upload_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/agri_resources/agri_resources_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ==========================================================
  // NAVIGATION HELPER
  // ==========================================================

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HEADER ROW
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Agrii Assist AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            _openScreen(context, const ProfileScreen());
                          },

                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,

                            child: Icon(
                              Icons.person,
                              color: Color(0xFF2E7D32),
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // GREETING
                    // ==================================================
                    const Text(
                      "Good Morning 🌱",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Welcome to your Smart Farming Assistant",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // FEATURES TITLE
              // ==================================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Features",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // FEATURES GRID
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: GridView.count(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  crossAxisSpacing: 15,

                  mainAxisSpacing: 15,

                  childAspectRatio: 1.1,

                  children: [
                    // ==================================================
                    // CROP ADVISOR
                    // ==================================================
                    _feature(
                      context,
                      Icons.eco,
                      "Crop Advisor",
                      Colors.lightGreen,
                    ),

                    // ==================================================
                    // AI CHATBOT
                    // ==================================================
                    _feature(
                      context,
                      Icons.smart_toy,
                      "AI Chatbot",
                      Colors.deepPurple,
                    ),

                    // ==================================================
                    // FARMER UPLOAD
                    // ==================================================
                    _feature(
                      context,
                      Icons.cloud_upload,
                      "Farmer Upload",
                      Colors.orange,
                    ),

                    // ==================================================
                    // PROFILE
                    // ==================================================
                    _feature(context, Icons.person, "Profile", Colors.indigo),

                    // ==================================================
                    // AGRI RESOURCES & MATERIALS
                    // ==================================================
                    _feature(
                      context,
                      Icons.category,
                      "Agri Resources & Materials",
                      Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // INFORMATION CARD
              // ==================================================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.agriculture, color: Colors.green, size: 60),

                    SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "Use AI technology to receive "
                        "farming advice, upload your products "
                        "for admin approval, and improve productivity.",

                        style: TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),

      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        selectedItemColor: const Color(0xFF2E7D32),

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          switch (index) {
            // ==================================================
            // HOME
            // ==================================================

            case 0:
              break;

            // ==================================================
            // CHATBOT
            // ==================================================

            case 1:
              _openScreen(context, const ChatbotScreen());
              break;

            // ==================================================
            // UPLOAD
            // ==================================================

            case 2:
              _openScreen(context, const FarmerUploadScreen());
              break;

            // ==================================================
            // PROFILE
            // ==================================================

            case 3:
              _openScreen(context, const ProfileScreen());
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Chat"),

          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: "Upload",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ==========================================================
  // FEATURE CARD
  // ==========================================================

  Widget _feature(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Card(
      elevation: 5,

      shadowColor: Colors.black12,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: () {
          switch (title) {
            // ==================================================
            // CROP ADVISOR
            // ==================================================

            case "Crop Advisor":
              _openScreen(context, const CropAdvisorScreen());
              break;

            // ==================================================
            // CHATBOT
            // ==================================================

            case "AI Chatbot":
              _openScreen(context, const ChatbotScreen());
              break;

            // ==================================================
            // FARMER UPLOAD
            // ==================================================

            case "Farmer Upload":
              _openScreen(context, const FarmerUploadScreen());
              break;

            // ==================================================
            // PROFILE
            // ==================================================

            case "Profile":
              _openScreen(context, const ProfileScreen());
              break;

            // ==================================================
            // AGRI RESOURCES & MATERIALS
            // ==================================================

            case "Agri Resources & Materials":
              _openScreen(context, const AgriResourcesScreen());
              break;
          }
        },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // ==================================================
            // ICON
            // ==================================================
            CircleAvatar(
              radius: 35,

              backgroundColor: color.withValues(alpha: 0.15),

              child: Icon(icon, color: color, size: 38),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // TITLE
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),

              child: Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
