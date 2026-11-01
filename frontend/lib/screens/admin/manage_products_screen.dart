import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  String selectedFilter = 'All'; // 'All', 'pending', 'approved', 'rejected'
  final TextEditingController _searchController = TextEditingController();

  // Track immediate local state during API calls
  final Map<String, String> actionStatus = {};

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/products"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data["products"] ?? []);
            actionStatus.clear();
            _applyFilters();
          });
        }
      }
    } catch (e) {
      debugPrint("FETCH PRODUCTS ERROR: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredProducts = products.where((p) {
        final dbStatus =
            (p["approvalStatus"] ?? "pending").toString().toLowerCase();

        final matchesStatus = selectedFilter == 'All' || dbStatus == selectedFilter;

        final name = (p["name"] ?? "").toString().toLowerCase();
        final cat = (p["category"] ?? "").toString().toLowerCase();
        final seller = p["seller"] is Map ? p["seller"] : {};
        final sellerName = (seller["name"] ?? "").toString().toLowerCase();

        final matchesQuery = query.isEmpty ||
            name.contains(query) ||
            cat.contains(query) ||
            sellerName.contains(query);

        return matchesStatus && matchesQuery;
      }).toList();
    });
  }

  Future<void> approveProduct(String id) async {
    setState(() => actionStatus[id] = 'approving');

    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.adminUrl}/products/$id/approve"),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Harvest Approved & Activated"),
              backgroundColor: Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
            ),
          );

          setState(() {
            final index = products.indexWhere((p) => p["_id"] == id);
            if (index != -1) {
              products[index] = data["product"] ?? products[index];
            }
            actionStatus.remove(id);
            _applyFilters();
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
        backgroundColor: AdminTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AdminTheme.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTheme.danger.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.cancel_rounded, color: AdminTheme.danger, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "Reject Submission",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AdminTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AdminTheme.textPrimary),
          decoration: InputDecoration(
            labelText: "Reason for Rejection",
            hintText: "State quality or details issue...",
            labelStyle: const TextStyle(color: AdminTheme.textSecondary),
            hintStyle: const TextStyle(color: AdminTheme.textMuted),
            filled: true,
            fillColor: AdminTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AdminTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AdminTheme.danger, width: 1.5),
            ),
          ),
          maxLines: 3,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.textMuted),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Confirm Reject", style: TextStyle(fontWeight: FontWeight.w700)),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Product Rejected"),
              backgroundColor: Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );

          setState(() {
            final index = products.indexWhere((p) => p["_id"] == id);
            if (index != -1) {
              products[index] = data["product"] ?? products[index];
            }
            actionStatus.remove(id);
            _applyFilters();
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
    final pendingCount = products.where((p) => (p["approvalStatus"] ?? "pending").toString().toLowerCase() == "pending").length;
    final approvedCount = products.where((p) => (p["approvalStatus"] ?? "").toString().toLowerCase() == "approved").length;
    final rejectedCount = products.where((p) => (p["approvalStatus"] ?? "").toString().toLowerCase() == "rejected").length;

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Column(
        children: [
          // ==========================================
          // TOP CYBER DARK & ELECTRIC LIME APPBAR
          // ==========================================
          Container(
            decoration: const BoxDecoration(
              gradient: AdminTheme.appBarGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AdminTheme.limeBorder,
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AdminTheme.limeGlow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AdminTheme.surfaceElevated,
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
                                  "Manage Products",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AdminTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminTheme.limeChip(
                                "${products.length} TOTAL",
                                icon: Icons.inventory_2_rounded,
                                isSolid: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Approve or reject farmer harvest listings",
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
                        color: AdminTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        tooltip: "Refresh products",
                        onPressed: fetchProducts,
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
          // SEARCH BAR
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: "Search harvest, category, farmer...",
                  hintStyle: const TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AdminTheme.lime,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AdminTheme.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ==========================================
          // STATUS FILTER CHIPS
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _filterChip("All", "All", products.length),
                const SizedBox(width: 8),
                _filterChip("Pending", "pending", pendingCount, isAmber: true),
                const SizedBox(width: 8),
                _filterChip("Approved", "approved", approvedCount),
                const SizedBox(width: 8),
                _filterChip("Rejected", "rejected", rejectedCount, isRose: true),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ==========================================
          // LIST OF PRODUCTS
          // ==========================================
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.lime),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading farmer submissions...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty
                    ? _emptyView()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surfaceElevated,
                        onRefresh: fetchProducts,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredProducts.length,
                          itemBuilder: (ctx, i) => _productCard(filteredProducts[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, int count, {bool isAmber = false, bool isRose = false}) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = value;
            _applyFilters();
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
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AdminTheme.limeGlow,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.black : AdminTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black87 : AdminTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    final id = p["_id"]?.toString() ?? "";
    final imageUrl = p["image"]?.toString() ?? "";
    final String dbStatus = (p["approvalStatus"] ?? "pending").toString().toLowerCase();
    final String? action = actionStatus[id];

    final seller = p["seller"] is Map ? p["seller"] : {};
    final sellerName = seller["name"] ?? "Verified Farmer";
    final sellerPhone = seller["phone"] ?? "N/A";
    final sellerAddress = seller["farmLocation"] ?? "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AdminTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Header: Image + Name + Price & Quantity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p["name"] ?? "Unknown Harvest",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AdminTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusPill(dbStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Category: ${p["category"] ?? 'General'}",
                        style: const TextStyle(
                          color: AdminTheme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "₹${p["price"] ?? 0}",
                            style: const TextStyle(
                              color: AdminTheme.lime,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• ${p["quantity"] ?? 0} ${p["unit"] ?? "Kg"}",
                            style: const TextStyle(
                              color: AdminTheme.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Seller Details Strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(
                children: [
                  _sellerRow(Icons.person_rounded, "Seller", sellerName),
                  const SizedBox(height: 6),
                  _sellerRow(Icons.phone_rounded, "Phone", sellerPhone),
                  const SizedBox(height: 6),
                  _sellerRow(Icons.location_on_rounded, "Location", sellerAddress),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Action / Status Area
            _buildActionArea(id, dbStatus, action, p),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    if (status == "approved") {
      return AdminTheme.limeChip(
        "APPROVED",
        icon: Icons.check_circle_rounded,
        isSolid: true,
      );
    } else if (status == "rejected") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
        decoration: BoxDecoration(
          color: AdminTheme.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminTheme.danger),
        ),
        child: const Text(
          "REJECTED",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AdminTheme.danger,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: AdminTheme.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.warning),
      ),
      child: const Text(
        "PENDING",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AdminTheme.warning,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sellerRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AdminTheme.lime),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AdminTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea(String id, String dbStatus, String? action, Map<String, dynamic> p) {
    if (action == 'approving' || action == 'rejecting') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AdminTheme.lime),
          ),
        ),
      );
    }

    if (dbStatus == 'approved') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AdminTheme.limeTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.limeBorder),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AdminTheme.lime, size: 18),
            SizedBox(width: 6),
            Text(
              "APPROVED & LIVE ON MARKETPLACE",
              style: TextStyle(
                color: AdminTheme.lime,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (dbStatus == 'rejected') {
      final reason = p["rejectionReason"] ?? "No specific reason provided";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AdminTheme.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.danger.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_rounded, color: AdminTheme.danger, size: 18),
                SizedBox(width: 6),
                Text(
                  "REJECTED BY ADMINISTRATOR",
                  style: TextStyle(
                    color: AdminTheme.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Reason: $reason",
              style: const TextStyle(
                color: AdminTheme.danger,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    // Default: Pending actions
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => approveProduct(id),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.black),
            label: const Text(
              "Approve",
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.lime,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: AdminTheme.limeGlow,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => rejectProduct(id),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminTheme.danger,
              side: const BorderSide(color: AdminTheme.danger, width: 1.2),
              backgroundColor: AdminTheme.surfaceElevated,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String imageUrl) {
    final String fullUrl = imageUrl.isNotEmpty
        ? (imageUrl.startsWith("http") ? imageUrl : ApiConstants.imageBaseUrl + imageUrl)
        : "";

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: AdminTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: fullUrl.isNotEmpty
          ? Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.inventory_2_rounded,
                color: AdminTheme.lime,
                size: 32,
              ),
            )
          : const Icon(
              Icons.inventory_2_rounded,
              color: AdminTheme.lime,
              size: 32,
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
              color: AdminTheme.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AdminTheme.limeBorder),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Products Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "No products match your active search or status filter.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
