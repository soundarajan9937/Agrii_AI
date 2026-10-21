import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Widget helpCard(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
  ) {
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$title clicked")));
        },
      ),
    );
  }

  Widget faqCard(String question, String answer) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.green),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(answer, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.green,
                child: Icon(Icons.support_agent, color: Colors.white, size: 45),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                "Need Help?",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                "We're here to help you with Agrii Assist AI.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Contact Us",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            helpCard(Icons.phone, "Call Support", "+91 9876543210", context),

            helpCard(
              Icons.email,
              "Email Support",
              "support@agriiassistai.com",
              context,
            ),

            helpCard(
              Icons.chat,
              "Live Chat",
              "Chat with our support team",
              context,
            ),

            helpCard(
              Icons.bug_report,
              "Report a Problem",
              "Send bug reports",
              context,
            ),

            helpCard(
              Icons.feedback,
              "Send Feedback",
              "Help us improve",
              context,
            ),

            const SizedBox(height: 25),

            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            faqCard(
              "How do I detect crop diseases?",
              "Open Disease Detection, upload a crop image, and Agrii Assist AI will analyze it.",
            ),

            faqCard(
              "Can I save my reports?",
              "Yes. Disease reports can be saved and viewed later from Saved Crop Reports.",
            ),

            faqCard(
              "Does the chatbot support multiple languages?",
              "Yes. English, Tamil and Hindi are supported.",
            ),

            faqCard(
              "Is internet required?",
              "Yes. AI analysis requires an internet connection.",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
