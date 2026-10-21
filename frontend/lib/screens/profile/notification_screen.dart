import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool weatherNotification = true;
  bool diseaseAlert = true;
  bool marketNotification = true;
  bool chatbotNotification = false;
  bool appUpdate = true;

  Widget notificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        value: value,
        activeThumbColor: Colors.green,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text("Notifications"),
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
              child: Icon(Icons.notifications, color: Colors.white, size: 45),
            ),

            const SizedBox(height: 15),

            const Text(
              "Notification Settings",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Manage your notification preferences",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            notificationTile(
              "Weather Alerts",
              "Receive weather updates",
              Icons.cloud,
              weatherNotification,
              (value) {
                setState(() {
                  weatherNotification = value;
                });
              },
            ),

            notificationTile(
              "Disease Alerts",
              "Receive crop disease alerts",
              Icons.coronavirus,
              diseaseAlert,
              (value) {
                setState(() {
                  diseaseAlert = value;
                });
              },
            ),

            notificationTile(
              "Marketplace Updates",
              "Receive market price updates",
              Icons.shopping_cart,
              marketNotification,
              (value) {
                setState(() {
                  marketNotification = value;
                });
              },
            ),

            notificationTile(
              "AI Chatbot",
              "Receive AI assistant notifications",
              Icons.smart_toy,
              chatbotNotification,
              (value) {
                setState(() {
                  chatbotNotification = value;
                });
              },
            ),

            notificationTile(
              "App Updates",
              "Notify when a new version is available",
              Icons.system_update,
              appUpdate,
              (value) {
                setState(() {
                  appUpdate = value;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Settings",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Notification settings saved"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
