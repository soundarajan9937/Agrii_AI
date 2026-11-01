import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../login/login_screen.dart';
import '../../core/constants/theme/auth_theme.dart';
import 'admin_agri_resources_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_payments_screen.dart';
import 'manage_products_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ==========================================================
  // DASHBOARD DATA
  // ==========================================================
  int totalUsers = 0;
  int totalFarmers = 0;
  int totalProducts = 0;

  int pendingProducts = 0;
  int approvedProducts = 0;

  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;

  int totalPayments = 0;
  double totalRevenue = 0;
  double codAmount = 0;
  double gpayAmount = 0;
  double phonepeAmount = 0;

  // ==========================================================
  // STATE
  // ==========================================================
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboardStats();
  }

  // ==========================================================
  // LOAD DASHBOARD STATISTICS
  // ==========================================================
  Future<void> loadDashboardStats() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final String? token =
          prefs.getString("adminToken") ?? prefs.getString("token");

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Session expired. Please login again.";
        });
        return;
      }

      final response = await http
          .get(
            Uri.parse("${ApiConstants.adminUrl}/dashboard"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is! Map<String, dynamic>) {
          throw Exception("Invalid server response.");
        }

        final dynamic stats = decodedData["stats"] ?? decodedData["statistics"];

        if (stats == null || stats is! Map<String, dynamic>) {
          throw Exception("Dashboard statistics not found.");
        }

        setState(() {
          totalUsers = _toInt(stats["totalUsers"]);
          totalFarmers = _toInt(stats["totalFarmers"]);
          totalProducts = _toInt(stats["totalProducts"]);
          pendingProducts = _toInt(stats["pendingProducts"]);
          approvedProducts = _toInt(stats["approvedProducts"]);
          totalOrders = _toInt(stats["totalOrders"]);
          pendingOrders = _toInt(stats["pendingOrders"]);
          deliveredOrders = _toInt(stats["deliveredOrders"]);
          totalPayments = _toInt(stats["totalPayments"]);
          totalRevenue = _toDouble(stats["totalRevenue"]);
          codAmount = _toDouble(stats["codAmount"]);
          gpayAmount = _toDouble(stats["gpayAmount"]);
          phonepeAmount = _toDouble(stats["phonepeAmount"]);

          isLoading = false;
          errorMessage = null;
        });
        return;
      }

      String message = "Server Error: ${response.statusCode}";
      try {
        final dynamic errorData = jsonDecode(response.body);
        if (errorData is Map && errorData["message"] != null) {
          message = errorData["message"].toString();
        }
      } catch (_) {}

      setState(() {
        isLoading = false;
        errorMessage = message;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
            "Connection failed.\nBackend not reachable at ${ApiConstants.serverIp}:${ApiConstants.port}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Error loading stats: $e";
      });
    }
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "0") ?? 0.0;
  }

  Future<void> logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                child: const Icon(
                  Icons.logout_rounded,
                  color: AdminTheme.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Sign Out",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AdminTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to exit the Agrii AI Administrator Console?",
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: AdminTheme.textMuted),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Column(
        children: [
          // ==========================================
          // EXECUTIVE DARK OBSIDIAN & ELECTRIC LIME APP BAR
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
                  blurRadius: 18,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AdminTheme.limeTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AdminTheme.limeBorder,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AdminTheme.lime,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  "Admin Console",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AdminTheme.textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AdminTheme.limeChip(
                                "ROOT",
                                icon: Icons.bolt_rounded,
                                isSolid: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Agrii AI Operations & Verification",
                            style: TextStyle(
                              color: AdminTheme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Action: Refresh
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AdminTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: "Refresh Statistics",
                        icon: const Icon(Icons.refresh_rounded, color: AdminTheme.lime, size: 20),
                        onPressed: isLoading ? null : loadDashboardStats,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Action: Logout
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AdminTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: "Logout",
                        icon: const Icon(Icons.logout_rounded, color: AdminTheme.textSecondary, size: 20),
                        onPressed: logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // BODY
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
                          "Loading dashboard insights...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? _buildErrorView()
                    : RefreshIndicator(
                        onRefresh: loadDashboardStats,
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surfaceElevated,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ------------------------------------
                              // HERO REVENUE STRIP (IF REVENUE > 0)
                              // ------------------------------------
                              if (totalRevenue > 0) ...[
                                _buildRevenueHero(),
                                const SizedBox(height: 18),
                              ],

                              // ------------------------------------
                              // SECTION HEADER: PLATFORM OVERVIEW
                              // ------------------------------------
                              Row(
                                children: const [
                                  Icon(Icons.dashboard_customize_rounded,
                                      size: 18, color: AdminTheme.lime),
                                  SizedBox(width: 8),
                                  Text(
                                    "Platform Overview",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AdminTheme.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ------------------------------------
                              // 2x2 CORE STATS GRID
                              // ------------------------------------
                              _buildStatsGrid(),

                              const SizedBox(height: 24),

                              // ------------------------------------
                              // SECTION HEADER: ACTION & STATUS RADAR
                              // ------------------------------------
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.radar_rounded,
                                          size: 18, color: AdminTheme.lime),
                                      SizedBox(width: 8),
                                      Text(
                                        "Activity & Approval Radar",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AdminTheme.textPrimary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _statusRadarTile(
                                title: "Pending Products",
                                subtitle: "Farmer submissions waiting for review",
                                value: pendingProducts.toString(),
                                icon: Icons.pending_actions_rounded,
                                color: AdminTheme.warning,
                                isUrgent: pendingProducts > 0,
                                onTap: () => _navigateTo(const ManageProductsScreen()),
                              ),
                              const SizedBox(height: 10),

                              _statusRadarTile(
                                title: "Approved Harvests",
                                subtitle: "Active products live on consumer marketplace",
                                value: approvedProducts.toString(),
                                icon: Icons.verified_rounded,
                                color: AdminTheme.lime,
                                onTap: () => _navigateTo(const ManageProductsScreen()),
                              ),
                              const SizedBox(height: 10),

                              _statusRadarTile(
                                title: "Verified Farmers",
                                subtitle: "Producers actively listing crops & resources",
                                value: totalFarmers.toString(),
                                icon: Icons.agriculture_rounded,
                                color: AdminTheme.lime,
                                onTap: () => _navigateTo(const ManageUsersScreen()),
                              ),
                              const SizedBox(height: 10),

                              _statusRadarTile(
                                title: "Pending Deliveries",
                                subtitle: "Orders currently in transit or processing",
                                value: pendingOrders.toString(),
                                icon: Icons.hourglass_top_rounded,
                                color: AdminTheme.warning,
                                onTap: () => _navigateTo(const ManageOrdersScreen()),
                              ),
                              const SizedBox(height: 10),

                              _statusRadarTile(
                                title: "Delivered Orders",
                                subtitle: "Completed harvests successfully fulfilled",
                                value: deliveredOrders.toString(),
                                icon: Icons.local_shipping_rounded,
                                color: AdminTheme.lime,
                                onTap: () => _navigateTo(const ManageOrdersScreen()),
                              ),

                              const SizedBox(height: 26),

                              // ------------------------------------
                              // SECTION HEADER: MANAGEMENT PORTALS
                              // ------------------------------------
                              Row(
                                children: const [
                                  Icon(Icons.tune_rounded,
                                      size: 18, color: AdminTheme.lime),
                                  SizedBox(width: 8),
                                  Text(
                                    "Administrative Portals",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AdminTheme.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _portalCard(
                                title: "Manage Products",
                                description:
                                    "Approve new harvests, verify pricing & inspect descriptions",
                                icon: Icons.inventory_2_rounded,
                                color: AdminTheme.lime,
                                badgeText: pendingProducts > 0
                                    ? "$pendingProducts PENDING"
                                    : "ACTIVE",
                                isBadgeUrgent: pendingProducts > 0,
                                screen: const ManageProductsScreen(),
                              ),
                              const SizedBox(height: 12),

                              _portalCard(
                                title: "Manage Users & Farmers",
                                description:
                                    "Directory of verified growers, customers & contact info",
                                icon: Icons.groups_rounded,
                                color: AdminTheme.lime,
                                badgeText: "${totalFarmers + totalUsers} ACCOUNTS",
                                isBadgeUrgent: false,
                                screen: const ManageUsersScreen(),
                              ),
                              const SizedBox(height: 12),

                              _portalCard(
                                title: "Manage Orders & Logistics",
                                description:
                                    "Track deliveries, dispatched crops & customer fulfillment",
                                icon: Icons.local_shipping_rounded,
                                color: AdminTheme.lime,
                                badgeText: "$totalOrders ORDERS",
                                isBadgeUrgent: pendingOrders > 0,
                                screen: const ManageOrdersScreen(),
                              ),
                              const SizedBox(height: 12),

                              _portalCard(
                                title: "Payments & Financial Settlement",
                                description:
                                    "Audit online payouts, UPI/COD splits & farmer payouts",
                                icon: Icons.account_balance_wallet_rounded,
                                color: AdminTheme.lime,
                                badgeText: "₹${totalRevenue.toStringAsFixed(0)}",
                                isBadgeUrgent: false,
                                screen: const ManagePaymentsScreen(),
                              ),
                              const SizedBox(height: 12),

                              _portalCard(
                                title: "Manage Agri Resources",
                                description:
                                    "Review organic compost, bio-waste materials & tools",
                                icon: Icons.recycling_rounded,
                                color: AdminTheme.lime,
                                badgeText: "CIRCULAR AGRI",
                                isBadgeUrgent: false,
                                screen: const AdminAgriResourcesScreen(),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) {
      loadDashboardStats();
    });
  }

  // ==========================================================
  // REVENUE HERO BANNER - CYBER DARK & ELECTRIC LIME
  // ==========================================================
  Widget _buildRevenueHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AdminTheme.limeBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AdminTheme.limeGlow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  "TOTAL PLATFORM REVENUE",
                  style: TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              AdminTheme.limeChip(
                "GROSS AUDIT",
                icon: Icons.trending_up_rounded,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "₹${totalRevenue.toStringAsFixed(0)}",
            style: const TextStyle(
              color: AdminTheme.lime,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (codAmount > 0)
                _paymentBreakdownChip("COD", "₹${codAmount.toStringAsFixed(0)}"),
              if (gpayAmount > 0)
                _paymentBreakdownChip("GPay", "₹${gpayAmount.toStringAsFixed(0)}"),
              if (phonepeAmount > 0)
                _paymentBreakdownChip("PhonePe", "₹${phonepeAmount.toStringAsFixed(0)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentBreakdownChip(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.limeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: AdminTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: AdminTheme.lime,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CORE 2x2 METRICS GRID
  // ==========================================================
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: [
        _metricTile(
          title: "Customers",
          value: totalUsers.toString(),
          icon: Icons.people_alt_rounded,
          color: AdminTheme.lime,
          subtitle: "Registered Buyers",
          onTap: () => _navigateTo(const ManageUsersScreen()),
        ),
        _metricTile(
          title: "Harvests",
          value: totalProducts.toString(),
          icon: Icons.inventory_2_rounded,
          color: AdminTheme.lime,
          subtitle: "Market Products",
          onTap: () => _navigateTo(const ManageProductsScreen()),
        ),
        _metricTile(
          title: "Total Orders",
          value: totalOrders.toString(),
          icon: Icons.shopping_bag_rounded,
          color: AdminTheme.warning,
          subtitle: "Deliveries Placed",
          onTap: () => _navigateTo(const ManageOrdersScreen()),
        ),
        _metricTile(
          title: "Local Farmers",
          value: totalFarmers.toString(),
          icon: Icons.agriculture_rounded,
          color: AdminTheme.lime,
          subtitle: "Registered Growers",
          onTap: () => _navigateTo(const ManageUsersScreen()),
        ),
      ],
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AdminTheme.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATUS RADAR TILE
  // ==========================================================
  Widget _statusRadarTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
    bool isUrgent = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AdminTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUrgent ? color.withValues(alpha: 0.6) : AdminTheme.border,
              width: isUrgent ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isUrgent)
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AdminTheme.limeChip(
                value,
                isSolid: isUrgent,
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AdminTheme.lime,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ADMINISTRATIVE PORTAL CARD
  // ==========================================================
  Widget _portalCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String badgeText,
    required bool isBadgeUrgent,
    required Widget screen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateTo(screen),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdminTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBadgeUrgent ? AdminTheme.limeBorder : AdminTheme.border,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AdminTheme.lime,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AdminTheme.limeGlow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AdminTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AdminTheme.limeChip(
                          badgeText,
                          isSolid: isBadgeUrgent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AdminTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminTheme.limeBorder),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AdminTheme.lime,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR VIEW
  // ==========================================================
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminTheme.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AdminTheme.danger.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AdminTheme.danger,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Connection Issue",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AdminTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? "Unable to fetch administrator data.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AdminTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadDashboardStats,
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.black),
              label: const Text(
                "Retry Connection",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.lime,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
