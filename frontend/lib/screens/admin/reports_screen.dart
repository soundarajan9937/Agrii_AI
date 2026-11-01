import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

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
      final token = prefs.getString("adminToken") ?? prefs.getString("token");
      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/dashboard"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() => stats = data["statistics"]);
        }
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
                                  "Intelligence & Reports",
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
                              AdminTheme.limeChip("SYSTEM AUDIT"),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Platform performance & marketplace telemetry",
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
                        tooltip: "Refresh telemetry",
                        onPressed: isLoading ? null : fetchStats,
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
          // STATS BODY
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
                          "Aggregating analytics telemetry...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : stats == null
                    ? _emptyView()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surface,
                        onRefresh: fetchStats,
                        child: ListView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            // Hero Revenue Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: AdminTheme.cardDecoration(glow: true),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.query_stats_rounded, color: AdminTheme.lime, size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            "GROSS ECOSYSTEM REVENUE",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: AdminTheme.textSecondary,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      AdminTheme.limeChip("+28.4%"),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "₹${stats!["totalRevenue"] ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: AdminTheme.lime,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Verified trading volume across agricultural and bio-waste supplies.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AdminTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 2x2 Telemetry Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _metricCard(
                                    "Total Users",
                                    "${stats!["totalUsers"] ?? 0}",
                                    Icons.people_alt_rounded,
                                    const Color(0xFF38BDF8),
                                    "Active Buyers",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _metricCard(
                                    "Farmers Network",
                                    "${stats!["totalFarmers"] ?? 0}",
                                    Icons.agriculture_rounded,
                                    AdminTheme.lime,
                                    "Certified Growers",
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _metricCard(
                                    "Approved Crops",
                                    "${stats!["approvedProducts"] ?? 0}",
                                    Icons.eco_rounded,
                                    AdminTheme.lime,
                                    "Market Verified",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _metricCard(
                                    "Delivered Orders",
                                    "${stats!["deliveredOrders"] ?? 0}",
                                    Icons.local_shipping_rounded,
                                    const Color(0xFFFBBF24),
                                    "Fulfilled Safely",
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Quick Action: Export / Download Report (Solid Lime Pill Button)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Exporting audit snapshot to encrypted file..."),
                                      backgroundColor: AdminTheme.surfaceElevated,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: AdminTheme.lime, width: 1.2),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.lime,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: const Icon(Icons.download_rounded, color: Colors.black, size: 20),
                                label: const Text(
                                  "Download System Audit (CSV)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color iconColor, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.cardDecoration(glow: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Icon(Icons.arrow_upward_rounded, color: AdminTheme.lime, size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AdminTheme.textMuted,
            ),
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
              Icons.query_stats_rounded,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Telemetry Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "System metrics will be updated upon data ingestion.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
