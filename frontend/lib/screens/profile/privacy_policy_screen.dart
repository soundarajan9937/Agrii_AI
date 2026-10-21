import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget privacyCard(IconData icon, String title, String description) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green,
              child: Icon(Icons.privacy_tip, size: 45, color: Colors.white),
            ),

            const SizedBox(height: 15),

            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your privacy is important to us.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 25),

            privacyCard(
              Icons.person,
              "Personal Information",
              "We securely store your profile details like name, email, phone number and farm information.",
            ),

            privacyCard(
              Icons.photo,
              "Crop Images",
              "Uploaded crop images are used only for AI disease detection and recommendations.",
            ),

            privacyCard(
              Icons.lock,
              "Data Security",
              "Your information is protected using secure storage and encrypted communication.",
            ),

            privacyCard(
              Icons.smart_toy,
              "AI Analysis",
              "Messages and crop images are processed only to provide AI-powered farming assistance.",
            ),

            privacyCard(
              Icons.notifications,
              "Notifications",
              "You can enable or disable notifications at any time from Settings.",
            ),

            privacyCard(
              Icons.share,
              "Data Sharing",
              "We do not sell or share your personal information with third parties without your permission.",
            ),

            privacyCard(
              Icons.update,
              "Policy Updates",
              "This privacy policy may be updated periodically to improve transparency and security.",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "I Understand",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}