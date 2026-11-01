import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;
  bool isUpdating = false;
  String selectedFilter = 'all'; // all, pending, accepted, delivered

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
            _applyFilter();
          });
        }
      }
    } catch (error) {
      debugPrint("FETCH ORDERS ERROR: $error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (selectedFilter == 'all') {
        filteredOrders = List.from(orders);
      } else {
        filteredOrders = orders.where((o) => (o["status"] ?? "").toString().toLowerCase() == selectedFilter).toList();
      }
    });
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Order marked as ${newStatus.toUpperCase()}"),
              backgroundColor: AdminTheme.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AdminTheme.lime, width: 1.2),
              ),
            ),
          );
          fetchOrders();
        }
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
      backgroundColor: AdminTheme.background,
      body: Column(
        children: [
          // ==========================================
          // TOP CYBER LIME APPBAR
          // ==========================================
          Container(
            decoration: BoxDecoration(
              gradient: AdminTheme.appBarGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: const Border(
                bottom: BorderSide(color: AdminTheme.limeBorder, width: 1),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300FF00),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AdminTheme.lime,
                          size: 18,
                        ),
                        tooltip: "Back",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  "Order Control Center",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminTheme.limeChip("${orders.length} ORDERS"),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Fulfillment & transaction tracking",
                            style: TextStyle(
                              fontSize: 12,
                              color: AdminTheme.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        tooltip: "Refresh orders",
                        onPressed: fetchOrders,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AdminTheme.lime,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // STATUS FILTER TABS (SOLID LIME PILLS)
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                _filterPill("All", "all", orders.length),
                const SizedBox(width: 8),
                _filterPill("Pending", "pending", orders.where((o) => (o["status"] ?? "").toLowerCase() == "pending").length),
                const SizedBox(width: 8),
                _filterPill("Accepted", "accepted", orders.where((o) => (o["status"] ?? "").toLowerCase() == "accepted").length),
                const SizedBox(width: 8),
                _filterPill("Delivered", "delivered", orders.where((o) => (o["status"] ?? "").toLowerCase() == "delivered").length),
              ],
            ),
          ),

          // ==========================================
          // ORDER LIST
          // ==========================================
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.lime),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading marketplace transactions...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredOrders.isEmpty
                    ? _emptyView()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surface,
                        onRefresh: fetchOrders,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: filteredOrders.length,
                          itemBuilder: (ctx, i) => _orderCard(filteredOrders[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String label, String value, int count) {
    final isSelected = selectedFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = value;
            _applyFilter();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.lime : AdminTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AdminTheme.lime : AdminTheme.border,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x5500FF00),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.black87 : AdminTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final buyerName = o["buyerName"] ?? (o["buyer"] is Map ? o["buyer"]["name"] : "N/A");
    final sellerName = o["sellerName"] ?? (o["seller"] is Map ? o["seller"]["name"] : "N/A");
    final productName = o["productName"] ?? (o["product"] is Map ? o["product"]["name"] : "Agricultural Product");
    final currentStatus = (o["status"] ?? "pending").toString().toLowerCase();
    final rawId = o["_id"]?.toString() ?? "000000";
    final shortId = rawId.length > 6 ? rawId.substring(rawId.length - 6).toUpperCase() : rawId.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AdminTheme.cardDecoration(glow: false),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AdminTheme.lime.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.limeBorder),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AdminTheme.lime, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "#$shortId",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AdminTheme.lime,
                      fontSize: 13,
                      letterSpacing: 0.8,
                      fontFamily: "monospace",
                    ),
                  ),
                ],
              ),
              _statusBadge(currentStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            productName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 15, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    const Text("Buyer: ", style: TextStyle(fontSize: 12, color: AdminTheme.textMuted, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        buyerName.toString(),
                        style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.agriculture_rounded, size: 15, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 8),
                    const Text("Farmer: ", style: TextStyle(fontSize: 12, color: AdminTheme.textMuted, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        sellerName.toString(),
                        style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AdminTheme.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOTAL SETTLEMENT", style: TextStyle(fontSize: 10, color: AdminTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    "₹${o["totalAmount"] ?? 0}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AdminTheme.lime,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                color: AdminTheme.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AdminTheme.limeBorder),
                ),
                onSelected: isUpdating ? null : (val) => updateOrderStatus(o["_id"], val),
                itemBuilder: (ctx) => [
                  _statusMenuItem("pending", "MARK PENDING", Icons.hourglass_top_rounded, Colors.amber),
                  _statusMenuItem("accepted", "ACCEPT ORDER", Icons.check_circle_outline_rounded, AdminTheme.lime),
                  _statusMenuItem("delivered", "DELIVERED", Icons.local_shipping_rounded, const Color(0xFF38BDF8)),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.limeBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down_rounded, color: AdminTheme.lime, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _statusMenuItem(String value, String title, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = const Color(0x22FBBF24);
    Color text = const Color(0xFFFBBF24);
    Color border = const Color(0x55FBBF24);

    if (status == "delivered" || status == "accepted") {
      bg = AdminTheme.lime.withValues(alpha: 0.15);
      text = AdminTheme.lime;
      border = AdminTheme.limeBorder;
    } else if (status == "cancelled" || status == "rejected") {
      bg = const Color(0x22EF4444);
      text = const Color(0xFFEF4444);
      border = const Color(0x55EF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AdminTheme.limeBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300FF00),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Orders Recorded",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Transactions will appear here once farmers and buyers trade.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
