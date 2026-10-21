import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../login/login_screen.dart';
import 'manage_products_screen.dart';
import 'manage_users_screen.dart';
import 'reports_screen.dart';
import 'admin_agri_resources_screen.dart';

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

  // ==========================================================
  // INIT
  // ==========================================================

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

      // ------------------------------------------------------
      // IMPORTANT:
      // Check mounted after async operation
      // ------------------------------------------------------

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

      // ------------------------------------------------------
      // API REQUEST
      // ------------------------------------------------------

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

      // ------------------------------------------------------
      // CHECK WIDGET STILL EXISTS
      // ------------------------------------------------------

      if (!mounted) return;

      // ------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------

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

      // ------------------------------------------------------
      // SERVER ERROR
      // ------------------------------------------------------

      String message = "Server Error: ${response.statusCode}";

      try {
        final dynamic errorData = jsonDecode(response.body);

        if (errorData is Map && errorData["message"] != null) {
          message = errorData["message"].toString();
        }
      } catch (_) {
        // Ignore invalid error JSON
      }

      setState(() {
        isLoading = false;
        errorMessage = message;
      });
    } on SocketException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            "Connection failed.\n\n"
            "Make sure the backend is running at:\n"
            "${ApiConstants.serverIp}:${ApiConstants.port}";
      });
    } on http.ClientException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Network Error:\n$e";
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Server returned invalid JSON.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  // ==========================================================
  // NUMBER CONVERSION
  // ==========================================================

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? "0") ?? 0.0;
  }

  // ==========================================================
  // REVENUE FORMAT
  // ==========================================================

  String formatRevenue(double value) {
    return "₹${value.toStringAsFixed(0)}";
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    // --------------------------------------------------------
    // SHOW CONFIRMATION
    // --------------------------------------------------------

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    // --------------------------------------------------------
    // CLEAR SESSION
    // --------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    // --------------------------------------------------------
    // IMPORTANT:
    // mounted check AFTER async operation
    // --------------------------------------------------------

    if (!mounted) return;

    // --------------------------------------------------------
    // GO TO LOGIN
    // --------------------------------------------------------

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        actions: [
          // --------------------------------------------------
          // REFRESH
          // --------------------------------------------------
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : loadDashboardStats,
          ),

          // --------------------------------------------------
          // LOGOUT
          // --------------------------------------------------
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: _buildBody(),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    // --------------------------------------------------------
    // LOADING
    // --------------------------------------------------------

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    // --------------------------------------------------------
    // ERROR
    // --------------------------------------------------------

    if (errorMessage != null) {
      return _errorView();
    }

    // --------------------------------------------------------
    // DASHBOARD
    // --------------------------------------------------------

    return RefreshIndicator(
      onRefresh: loadDashboardStats,
      color: Colors.green,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // ==================================================
            // MAIN STATISTICS
            // ==================================================
            _statsGrid(),

            const SizedBox(height: 20),

            // ==================================================
            // IMPORTANT INFORMATION
            // ==================================================
            _infoCard(
              "Pending Products",
              pendingProducts.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),

            _infoCard(
              "Approved Products",
              approvedProducts.toString(),
              Icons.verified,
              Colors.green,
            ),

            _infoCard(
              "Total Farmers",
              totalFarmers.toString(),
              Icons.agriculture,
              Colors.blue,
            ),

            _infoCard(
              "Pending Orders",
              pendingOrders.toString(),
              Icons.pending,
              Colors.orange,
            ),

            _infoCard(
              "Delivered Orders",
              deliveredOrders.toString(),
              Icons.local_shipping,
              Colors.green,
            ),

            const SizedBox(height: 25),

            // ==================================================
            // ADMIN MENU
            // ==================================================
            _menuTile(
              "Manage Products",
              "Approve or reject farmer products",
              Icons.inventory_2,
              Colors.orange,
              const ManageProductsScreen(),
            ),

            _menuTile(
              "Manage Users",
              "View users and farmers",
              Icons.people,
              Colors.blue,
              const ManageUsersScreen(),
            ),

            _menuTile(
              "Manage Agri Resources",
              "Approve or reject materials",
              Icons.category,
              Colors.purpleAccent,
              const AdminAgriResourcesScreen(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATISTICS GRID
  // ==========================================================

  Widget _statsGrid() {
    return GridView.count(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      crossAxisCount: 2,

      crossAxisSpacing: 12,

      mainAxisSpacing: 12,

      childAspectRatio: 1.5,

      children: [
        _dashboardCard(
          "Users",
          totalUsers.toString(),
          Icons.people,
          Colors.blue,
        ),

        _dashboardCard(
          "Products",
          totalProducts.toString(),
          Icons.inventory,
          Colors.orange,
        ),

        _dashboardCard(
          "Orders",
          totalOrders.toString(),
          Icons.shopping_cart,
          Colors.purple,
        ),

        _dashboardCard(
          "Farmers",
          totalFarmers.toString(),
          Icons.agriculture,
          Colors.green,
        ),
      ],
    );
  }

  // ==========================================================
  // ERROR VIEW
  // ==========================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.red),

            const SizedBox(height: 15),

            Text(
              errorMessage ?? "Something went wrong.",
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadDashboardStats,

              icon: const Icon(Icons.refresh),

              label: const Text("Retry"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DASHBOARD CARD
  // ==========================================================

  Widget _dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: color, size: 30),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMATION CARD
  // ==========================================================

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),

          child: Icon(icon, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),

        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ADMIN MENU TILE
  // ==========================================================

  Widget _menuTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),

        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),

          child: Icon(icon, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}
