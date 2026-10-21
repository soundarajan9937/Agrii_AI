import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("adminToken") ?? prefs.getString("token");
    final headers = <String, String>{"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.orderUrl}/admin/all";
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderList = data["orders"];
        if (orderList is List) {
          setState(() {
            orders = orderList.map((o) => Map<String, dynamic>.from(o as Map)).toList();
          });
        }
      }
    } catch (error) {
      debugPrint("FETCH ORDERS ERROR: $error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    setState(() => isUpdating = true);
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.orderUrl}/$orderId/status";
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated"), backgroundColor: Colors.green));
        fetchOrders();
      }
    } catch (error) {
      debugPrint("UPDATE ERROR: $error");
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders"), centerTitle: true, backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final o = orders[i];
                    final buyerName = o["buyerName"] ?? (o["buyer"] is Map ? o["buyer"]["name"] : "N/A");
                    final sellerName = o["sellerName"] ?? (o["seller"] is Map ? o["seller"]["name"] : "N/A");
                    final productName = o["productName"] ?? (o["product"] is Map ? o["product"]["name"] : "Product");

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order #${o["_id"].toString().substring(o["_id"].toString().length - 6)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                _statusChip(o["status"] ?? "pending"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("Buyer: $buyerName", style: const TextStyle(color: Colors.blue)),
                            Text("Seller: $sellerName", style: const TextStyle(color: Colors.orange)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total: ₹${o["totalAmount"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                DropdownButton<String>(
                                  value: o["status"] == "pending" ? "pending" : (o["status"] == "accepted" ? "accepted" : "delivered"),
                                  items: ["pending", "accepted", "delivered"]
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                                      .toList(),
                                  onChanged: isUpdating ? null : (val) {
                                    if (val != null) updateOrderStatus(o["_id"], val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    final s = status.toLowerCase();
    if (s == "delivered" || s == "accepted") color = Colors.green;
    if (s == "cancelled" || s == "rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
