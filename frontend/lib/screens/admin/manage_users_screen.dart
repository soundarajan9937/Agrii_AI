import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // Check both possible token keys
      final token = prefs.getString("adminToken") ?? prefs.getString("token");

      debugPrint("FETCHING USERS WITH TOKEN: ${token?.substring(0, 10)}...");

      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint("ADMIN USERS STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            users = data["users"] ?? [];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load users: ${response.statusCode}"), backgroundColor: Colors.red),
          );
        }
        debugPrint("FAILED TO LOAD USERS: ${response.body}");
      }
    } catch (e) {
      debugPrint("FETCH USERS ERROR: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection Error"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Manage Users & Farmers", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchUsers),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : users.isEmpty
              ? _emptyView()
              : RefreshIndicator(
                  onRefresh: fetchUsers,
                  color: Colors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (ctx, i) {
                      final u = users[i];
                      final bool isFarmer = u["role"] == "farmer";

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: isFarmer ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                            child: Icon(
                              isFarmer ? Icons.agriculture : Icons.person,
                              color: isFarmer ? Colors.orange : Colors.blue,
                            ),
                          ),
                          title: Text(
                            u["name"] ?? "No Name",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isFarmer ? "Farmer Account" : "User Account",
                            style: TextStyle(color: isFarmer ? Colors.orange : Colors.blue, fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _detailItem(Icons.phone, "Phone", u["phone"] ?? "N/A"),
                                  _detailItem(Icons.email, "Email", u["email"] ?? "N/A"),
                                  if (isFarmer) ...[
                                    _detailItem(Icons.home_work, "Farm Name", u["farmName"] ?? "N/A"),
                                    _detailItem(Icons.location_on, "Address", u["farmLocation"] ?? "N/A"),
                                  ],
                                  _detailItem(Icons.calendar_today, "Registered On", formatDate(u["createdAt"])),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          // Placeholder for Block/Unblock functionality
                                        },
                                        icon: Icon(Icons.block, color: Colors.red.shade400, size: 18),
                                        label: Text(u["status"] == "blocked" ? "Unblock" : "Block User",
                                          style: TextStyle(color: Colors.red.shade400)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          const Text("No users or farmers found", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
