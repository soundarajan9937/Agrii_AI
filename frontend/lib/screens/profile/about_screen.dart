import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget buildTile(IconData icon, String title, String subtitle) {
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
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text("About Agrii Assist AI"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(Icons.agriculture, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            const Text(
              "Agrii Assist AI",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Version 1.0.0",
              style: TextStyle(fontSize: 17, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "Agrii Assist AI is an Artificial Intelligence based Smart Agriculture Application. It helps farmers detect crop diseases, receive crop recommendations, chat with an AI assistant, monitor weather conditions, and sell products through the marketplace. Our mission is to make farming smarter, easier, and more productive.",
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),

            const SizedBox(height: 25),

            buildTile(Icons.person, "Developer", "Agrii Assist AI Team"),

            buildTile(
              Icons.email,
              "Support Email",
              "support@agriiassistai.com",
            ),

            buildTile(Icons.language, "Website", "www.agriiassistai.com"),

            buildTile(Icons.location_on, "Location", "Coimbatore, Tamil Nadu"),

            buildTile(Icons.star, "Application Version", "Version 1.0.0"),

            buildTile(Icons.copyright, "Copyright", "© 2026 Agrii Assist AI"),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
