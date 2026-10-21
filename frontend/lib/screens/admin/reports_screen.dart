import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("adminToken");
      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/dashboard"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => stats = data["statistics"]);
      }
    } catch (e) {
      debugPrint("FETCH STATS ERROR: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
              ? const Center(child: Text("No statistics available"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _reportTile("Total Revenue", "₹${stats!["totalRevenue"]}"),
                    _reportTile("Total Users", "${stats!["totalUsers"]}"),
                    _reportTile("Total Farmers", "${stats!["totalFarmers"]}"),
                    _reportTile("Approved Products", "${stats!["approvedProducts"]}"),
                    _reportTile("Delivered Orders", "${stats!["deliveredOrders"]}"),
                  ],
                ),
    );
  }

  Widget _reportTile(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
    );
  }
}
