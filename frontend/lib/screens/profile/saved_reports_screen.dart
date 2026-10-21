import 'package:flutter/material.dart';

class SavedReportsScreen extends StatelessWidget {
  const SavedReportsScreen({super.key});

  Widget reportCard(
    BuildContext context,
    String crop,
    String disease,
    String date,
    String status,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.description, color: Colors.green),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(disease, style: const TextStyle(color: Colors.grey)),

                      const SizedBox(height: 5),

                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Chip(
                  backgroundColor: Colors.green.shade100,
                  label: Text(status),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$crop Report Opened")),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text("View"),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$crop Report Deleted")),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text("Saved Crop Reports"),
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
              child: Icon(Icons.folder_copy, color: Colors.white, size: 45),
            ),

            const SizedBox(height: 15),

            const Text(
              "Saved Reports",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Your previous AI crop analysis reports",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            reportCard(
              context,
              "Rice",
              "Leaf Blast Disease",
              "20 July 2026",
              "Completed",
            ),

            reportCard(
              context,
              "Tomato",
              "Early Blight",
              "18 July 2026",
              "Completed",
            ),

            reportCard(
              context,
              "Cotton",
              "Healthy Crop",
              "14 July 2026",
              "Healthy",
            ),

            reportCard(
              context,
              "Banana",
              "Panama Disease",
              "10 July 2026",
              "Completed",
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
