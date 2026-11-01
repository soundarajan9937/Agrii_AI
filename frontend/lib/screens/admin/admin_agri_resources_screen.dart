import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

class AdminAgriResourcesScreen extends StatefulWidget {
  const AdminAgriResourcesScreen({super.key});

  @override
  State<AdminAgriResourcesScreen> createState() =>
      _AdminAgriResourcesScreenState();
}

class _AdminAgriResourcesScreenState extends State<AdminAgriResourcesScreen> {
  List<dynamic> allResources = [];
  List<dynamic> filteredResources = [];
  bool isLoading = true;
  String selectedFilter = 'All'; // 'All', 'pending', 'approved', 'rejected'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchResources() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token =
          prefs.getString("adminToken") ?? prefs.getString("token");

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
        final List<dynamic> list = jsonDecode(response.body)['resources'] ?? [];
        if (mounted) {
          setState(() {
            allResources = list;
            isLoading = false;
            _applyFilters();
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Admin Fetch Resources Error: $e");
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredResources = allResources.where((r) {
        final status = (r['status'] ?? 'pending').toString().toLowerCase();
        final matchesStatus =
            selectedFilter == 'All' || status == selectedFilter;

        final name = (r['name'] ?? '').toString().toLowerCase();
        final cat = (r['category'] ?? '').toString().toLowerCase();
        final seller = (r['sellerName'] ?? '').toString().toLowerCase();

        final matchesQuery = query.isEmpty ||
            name.contains(query) ||
            cat.contains(query) ||
            seller.contains(query);

        return matchesStatus && matchesQuery;
      }).toList();
    });
  }

  Future<void> _showRejectDialog(String id) async {
    final TextEditingController reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AdminTheme.border, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x33EF4444),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x66EF4444)),
              ),
              child: const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            const Text("Reject Resource", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
          ],
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: "Reason for Rejection",
            hintText: "Enter reason for rejecting material...",
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
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.textSecondary),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Confirm Reject", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      _updateStatus(id, 'rejected', reason);
    }
  }

  Future<void> _updateStatus(String id, String status, [String? reason]) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString("adminToken") ?? prefs.getString("token") ?? "";

    final Map<String, dynamic> payload = {"status": status};
    if (reason != null && reason.isNotEmpty) {
      payload["rejectionReason"] = reason;
    }

    final response = await http.put(
      Uri.parse("${ApiConstants.agriResourceUrl}/admin/status/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 && mounted) {
      _fetchResources();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Resource $status successfully"),
          backgroundColor: AdminTheme.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: status == 'approved' ? AdminTheme.lime : const Color(0xFFEF4444),
              width: 1.2,
            ),
          ),
        ),
      );
    }
  }

  String _buildImageUrl(String image) {
    final String value = image.trim();
    if (value.isEmpty) return "";
    if (value.startsWith("http://") || value.startsWith("https://")) return value;
    if (value.startsWith("/uploads/")) return "${ApiConstants.serverBaseUrl}$value";
    return "${ApiConstants.serverBaseUrl}/uploads/$value";
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = allResources
        .where((r) => (r['status'] ?? 'pending').toString().toLowerCase() == 'pending')
        .length;
    final approvedCount = allResources
        .where((r) => (r['status'] ?? '').toString().toLowerCase() == 'approved')
        .length;
    final rejectedCount = allResources
        .where((r) => (r['status'] ?? '').toString().toLowerCase() == 'rejected')
        .length;

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
                                  "Agri Resources",
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
                              AdminTheme.limeChip("${allResources.length} ITEMS"),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Approve bio-waste, compost & circular tools",
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
                        tooltip: "Refresh resources",
                        onPressed: _fetchResources,
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
          // SEARCH BAR (CYBER SURFACE)
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: "Search resource, category, farmer...",
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
          // STATUS FILTER CHIPS (SOLID LIME PILLS)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _filterChip("All", "All", allResources.length),
                const SizedBox(width: 8),
                _filterChip("Pending", "pending", pendingCount),
                const SizedBox(width: 8),
                _filterChip("Approved", "approved", approvedCount),
                const SizedBox(width: 8),
                _filterChip("Rejected", "rejected", rejectedCount),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ==========================================
          // LIST OF RESOURCES
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
                          "Loading circular resources...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredResources.isEmpty
                    ? _emptyView()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surface,
                        onRefresh: _fetchResources,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredResources.length,
                          itemBuilder: (context, index) =>
                              _buildAdminCard(filteredResources[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, int count) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = value;
            _applyFilters();
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.lime : AdminTheme.surface,
            borderRadius: BorderRadius.circular(14),
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10.5,
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

  Widget _buildAdminCard(Map<String, dynamic> r) {
    final status = (r['status'] ?? 'pending').toString().toLowerCase();
    final imageUrl = _buildImageUrl(r['image']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AdminTheme.cardDecoration(glow: false),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 82,
                    height: 82,
                    color: AdminTheme.surfaceElevated,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.compost_rounded,
                              color: AdminTheme.lime,
                              size: 32,
                            ),
                          )
                        : const Icon(
                            Icons.compost_rounded,
                            color: AdminTheme.lime,
                            size: 32,
                          ),
                  ),
                ),
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
                              r['name'] ?? 'Unknown Resource',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusPill(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Category: ${r['category'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: AdminTheme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹${r['price'] ?? 0}",
                        style: const TextStyle(
                          color: AdminTheme.lime,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Seller Strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, size: 15, color: AdminTheme.lime),
                  const SizedBox(width: 6),
                  Text(
                    r['sellerName'] ?? 'Farmer',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 4),
                  Text(
                    r['phoneNumber'] ?? 'N/A',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF38BDF8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Actions Area
            if (status == 'pending') ...[
              Row(
                children: [
                  // SOLID LIME PILL BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(r['_id'], 'approved'),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.black),
                      label: const Text("Approve", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.lime,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(r['_id']),
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFEF4444)),
                      label: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x66EF4444), width: 1.2),
                        backgroundColor: const Color(0x22EF4444),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AdminTheme.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminTheme.limeBorder),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AdminTheme.lime, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "APPROVED & LIVE ON APP",
                      style: TextStyle(
                        color: AdminTheme.lime,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'rejected') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0x22EF4444),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55EF4444)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 6),
                    Text(
                      "REJECTED BY ADMINISTRATOR",
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (r['rejectionReason'] != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Reason: ${r['rejectionReason']}",
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg = const Color(0x22FBBF24);
    Color border = const Color(0x55FBBF24);
    Color text = const Color(0xFFFBBF24);
    String label = "PENDING";

    if (status == "approved") {
      bg = AdminTheme.lime.withValues(alpha: 0.15);
      border = AdminTheme.limeBorder;
      text = AdminTheme.lime;
      label = "APPROVED";
    } else if (status == "rejected") {
      bg = const Color(0x22EF4444);
      border = const Color(0x55EF4444);
      text = const Color(0xFFEF4444);
      label = "REJECTED";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: text,
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
              Icons.recycling_rounded,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Resources Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "No agri resources match your search or status filter.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
