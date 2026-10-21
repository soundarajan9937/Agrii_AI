import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class AdminAgriResourcesScreen extends StatefulWidget {
  const AdminAgriResourcesScreen({super.key});

  @override
  State<AdminAgriResourcesScreen> createState() => _AdminAgriResourcesScreenState();
}

class _AdminAgriResourcesScreenState extends State<AdminAgriResourcesScreen> {
  List<dynamic> allResources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("adminToken") ?? prefs.getString("token");

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse("${ApiConstants.agriResourceUrl}/admin/all"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          allResources = jsonDecode(response.body)['resources'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Admin Fetch Error: $e");
    }
  }

  Future<void> _showRejectDialog(String id) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Resource"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter reason for rejection...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(id, 'rejected', reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String status, [String? reason]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("adminToken") ?? prefs.getString("token") ?? "";

    final response = await http.put(
      Uri.parse("${ApiConstants.agriResourceUrl}/admin/status/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "status": status,
        if (reason != null) "rejectionReason": reason,
      }),
    );

    if (response.statusCode == 200) {
      _fetchResources();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Resource $status successfully"),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Manage Agri Resources"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : allResources.isEmpty
              ? const Center(child: Text("No resources to review"))
              : RefreshIndicator(
                  onRefresh: _fetchResources,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: allResources.length,
                    itemBuilder: (context, index) {
                      final r = allResources[index];
                      return _buildAdminCard(r);
                    },
                  ),
                ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> r) {
    final status = r['status'] ?? 'pending';
    Color statusColor = Colors.orange;
    if (status == 'approved') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "${ApiConstants.serverBaseUrl}/uploads/${r['image']}",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100, height: 100, color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['name'] ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Category: ${r['category'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text("Seller: ${r['sellerName']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text("Phone: ${r['phoneNumber']}", style: const TextStyle(color: Colors.blue)),
                      Text("Price: ₹${r['price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status == 'pending') ...[
              const Divider(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(r['_id'], 'approved'),
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(r['_id']),
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ] else if (status == 'rejected' && r['rejectionReason'] != null) ...[
              const Divider(),
              Text("Rejection Reason: ${r['rejectionReason']}", style: const TextStyle(color: Colors.red, fontSize: 13, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
