import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  // Track immediate local state during API calls
  final Map<String, String> actionStatus = {};

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("adminToken") ?? prefs.getString("token");
    final headers = <String, String>{"Content-Type": "application/json"};
    if (token != null) headers["Authorization"] = "Bearer $token";
    return headers;
  }

  Future<void> fetchProducts() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("${ApiConstants.adminUrl}/products"), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data["products"] ?? []);
            actionStatus.clear();
          });
        }
      }
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> approveProduct(String id) async {
    setState(() => actionStatus[id] = 'approving');

    try {
      final response = await http.put(Uri.parse("${ApiConstants.adminUrl}/products/$id/approve"), headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Approved")));

        if (mounted) {
          setState(() {
            // Update the product in the local list so refresh isn't mandatory
            final index = products.indexWhere((p) => p["_id"] == id);
            if (index != -1) {
              products[index] = data["product"] ?? products[index];
            }
            actionStatus.remove(id);
          });
        }
      } else {
        setState(() => actionStatus.remove(id));
      }
    } catch (e) {
      debugPrint("APPROVE ERROR: $e");
      setState(() => actionStatus.remove(id));
    }
  }

  Future<void> rejectProduct(String id) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Product"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Reason for rejection",
            hintText: "Enter why this product is being rejected...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => actionStatus[id] = 'rejecting');

    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.adminUrl}/products/$id/reject"),
        headers: await _getHeaders(),
        body: jsonEncode({"rejectionReason": reason}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Rejected")));

        if (mounted) {
          setState(() {
            // Update local product data
            final index = products.indexWhere((p) => p["_id"] == id);
            if (index != -1) {
              products[index] = data["product"] ?? products[index];
            }
            actionStatus.remove(id);
          });
        }
      } else {
        setState(() => actionStatus.remove(id));
      }
    } catch (e) {
      debugPrint("REJECT ERROR: $e");
      setState(() => actionStatus.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Manage Products", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchProducts),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : products.isEmpty
              ? _emptyView()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    final id = p["_id"]?.toString() ?? "";
                    final imageUrl = p["image"]?.toString() ?? "";

                    // Current status from database
                    final String dbStatus = (p["approvalStatus"] ?? "pending").toString().toLowerCase();

                    // Ongoing local action (for loading spinners)
                    final String? action = actionStatus[id];

                    // Seller details
                    final seller = p["seller"] is Map ? p["seller"] : {};
                    final sellerName = seller["name"] ?? "N/A";
                    final sellerPhone = seller["phone"] ?? "N/A";
                    final sellerAddress = seller["farmLocation"] ?? "N/A";

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Info Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProductImage(imageUrl),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p["name"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 5),
                                      Text("Category: ${p["category"]}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                                      Text("Price: ₹${p["price"]}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("Quantity: ${p["quantity"]} ${p["unit"] ?? "Kg"}", style: const TextStyle(color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),

                            // Seller Info Section
                            const Text("Seller Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 8),
                            _detailRow(Icons.person, "Name", sellerName),
                            _detailRow(Icons.phone, "Phone", sellerPhone),
                            _detailRow(Icons.location_on, "Address", sellerAddress),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),

                            // Action Area (PERSISTENT STATUS)
                            _buildPersistentActionArea(id, dbStatus, action, p),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildPersistentActionArea(String id, String dbStatus, String? action, Map<String, dynamic> p) {
    // If currently performing an action, show loading
    if (action == 'approving') {
       return const Center(child: CircularProgressIndicator(color: Colors.green));
    }
    if (action == 'rejecting') {
       return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    // If status is APPROVED in database
    if (dbStatus == 'approved') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                "APPROVED",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      );
    }

    // If status is REJECTED in database
    if (dbStatus == 'rejected') {
      final reason = p["rejectionReason"] ?? "No reason provided";
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "REJECTED",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Reason: $reason",
              style: const TextStyle(color: Colors.red, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }

    // Default: Show buttons for PENDING products
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: "Approve",
            icon: Icons.check_circle_outline,
            activeColor: Colors.green,
            onPressed: () => approveProduct(id),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: "Reject",
            icon: Icons.cancel_outlined,
            activeColor: Colors.red,
            onPressed: () => rejectProduct(id),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
              ApiConstants.imageBaseUrl + imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.inventory_2, color: Colors.grey),
            )
          : const Icon(Icons.inventory_2, color: Colors.grey),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: activeColor),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("No products found", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
