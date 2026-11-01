import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_api_service.dart';
import '../../services/order_api_service.dart';
import '../login/login_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../crop_advisor/crop_advisor_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../agri_resources/farmer_agri_resources_screen.dart';
import '../profile/notifications_list_screen.dart';
import '../../services/notification_service.dart';

class FarmerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const FarmerHomeScreen({super.key, this.initialIndex = 0});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late int _currentIndex;

  String farmerName = "Farmer";
  String farmerEmail = "";
  String? userId;
  String? profileBase64;

  List<dynamic> myProducts = [];
  bool isLoadingProducts = true;

  List<dynamic> farmerOrders = [];
  bool isLoadingOrders = true;

  int unreadNotifications = 0;

  final MarketplaceApiService _apiService = MarketplaceApiService();
  final OrderApiService _orderApiService = OrderApiService();
  final NotificationService _notificationService = NotificationService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    loadFarmerData();
    loadMyProducts();
    loadFarmerOrders();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        unreadNotifications = count;
      });
    }
  }

  // ==========================================================
  // LOAD FARMER DATA
  // ==========================================================

  Future<void> loadFarmerData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final savedUserId = prefs.getString("userId");

    setState(() {
      userId = savedUserId;
      farmerName = prefs.getString("name") ?? "Farmer";
      farmerEmail = prefs.getString("email") ?? "";

      if (savedUserId != null) {
        profileBase64 = prefs.getString("profile_pic_data_$savedUserId");
      }
    });
  }

  // ==========================================================
  // PICK PROFILE IMAGE
  // ==========================================================

  Future<void> _pickImage() async {
    if (userId == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    final Uint8List bytes = await image.readAsBytes();
    final String base64Image = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();

    if (userId == null) return;

    await prefs.setString("profile_pic_data_$userId", base64Image);

    if (!mounted) return;

    setState(() {
      profileBase64 = base64Image;
    });

    _showSuccess("Profile picture updated!");
  }

  // ==========================================================
  // REMOVE PROFILE IMAGE
  // ==========================================================

  Future<void> _removeImage() async {
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("profile_pic_data_$userId");

    if (!mounted) return;

    setState(() {
      profileBase64 = null;
    });

    _showSuccess("Profile picture removed");
  }

  // ==========================================================
  // PROFILE OPTIONS
  // ==========================================================

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Profile Photo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: const Color(0xFFFFF7ED),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFFEA580C), size: 20),
                ),
                title: const Text(
                  "Choose from Gallery",
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 14),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFEA580C)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (profileBase64 != null) ...[
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: const Color(0xFFFEF2F2),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                  title: const Text(
                    "Remove Profile Photo",
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626), fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SUCCESS MESSAGE
  // ==========================================================

  void _showSuccess(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEA580C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==========================================================
  // LOAD MY PRODUCTS
  // ==========================================================

  Future<void> loadMyProducts() async {
    if (mounted) {
      setState(() {
        isLoadingProducts = true;
      });
    }

    try {
      final products = await _apiService.getMyProducts();

      if (!mounted) return;

      setState(() {
        myProducts = products;
        isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint("LOAD MY PRODUCTS ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  // ==========================================================
  // LOAD FARMER ORDERS
  // ==========================================================

  Future<void> loadFarmerOrders() async {
    if (mounted) {
      setState(() {
        isLoadingOrders = true;
      });
    }

    try {
      final orders = await _orderApiService.getFarmerOrders();

      if (!mounted) return;

      setState(() {
        farmerOrders = orders;
        isLoadingOrders = false;
      });
    } catch (e) {
      debugPrint("LOAD FARMER ORDERS ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  // ==========================================================
  // ACCEPT ORDER
  // ==========================================================

  Future<void> acceptOrder(String orderId) async {
    try {
      final bool success = await _orderApiService.acceptOrder(orderId);

      if (!mounted) return;

      if (success) {
        await loadFarmerOrders();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order Accepted!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("ACCEPT ORDER ERROR: $e");
    }
  }

  // ==========================================================
  // REJECT ORDER
  // ==========================================================

  Future<void> rejectOrder(String orderId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Order"),
        content: const Text("Are you sure you want to reject this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final bool success = await _orderApiService.cancelOrder(orderId);

      if (!mounted) return;

      if (success) {
        await loadFarmerOrders();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order Rejected"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("REJECT ORDER ERROR: $e");
    }
  }

  // ==========================================================
  // UPDATE ORDER STATUS
  // ==========================================================

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final bool success = await _orderApiService.updateStatus(orderId, status);

      if (!mounted) return;

      if (success) {
        await loadFarmerOrders();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order status updated to $status")),
        );
      }
    } catch (e) {
      debugPrint("UPDATE STATUS ERROR: $e");
    }
  }

  // ==========================================================
  // DELETE PRODUCT
  // ==========================================================

  Future<void> deleteProduct(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final bool success = await _apiService.deleteProduct(id);

      if (!mounted) return;

      if (success) {
        await loadMyProducts();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product deleted successfully"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                "Log Out",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to log out of your Agrii Farmer account?",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      buildHome(),
      buildProducts(),
      buildOrders(),
      buildProfile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFarmerNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: "Home",
                ),
                _buildFarmerNavItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: "Products",
                ),
                _buildFarmerNavItem(
                  index: 2,
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping_rounded,
                  label: "Orders",
                ),
                _buildFarmerNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    const Color activeColor = Color(0xFFEA580C);

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : const Color(0xFF94A3B8),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FARMER HOME
  // ==========================================================

  Widget buildHome() {
    Uint8List? imageBytes;

    if (profileBase64 != null) {
      try {
        imageBytes = base64Decode(profileBase64!);
      } catch (e) {
        debugPrint("Error decoding profile pic: $e");
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // TOP HEADER: AVATAR + GREETING + NOTIFICATIONS
            // ==================================================
            Row(
              children: [
                GestureDetector(
                  onTap: _showProfileOptions,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFDBA74),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFEA580C),
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : null,
                      child: imageBytes == null
                          ? const Icon(
                              Icons.agriculture_rounded,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "🌱 Grower",
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        farmerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifications Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        tooltip: "Notifications",
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsListScreen(),
                            ),
                          );
                          _loadUnreadCount();
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 22,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              unreadNotifications > 9 ? "9+" : "$unreadNotifications",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==================================================
            // FARMER WELCOME HERO BANNER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9A3412), // Deep Terracotta
                    Color(0xFFC2410C), // Warm Ochre
                    Color(0xFFEA580C), // Sunrise Orange
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Tractor Icon + Hub Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "🌱 Agrii AI Farm Hub",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Farmer Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Manage your farm products, orders and activities from one place.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Button + Live metrics
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddProductScreen(),
                            ),
                          );

                          if (result == true) {
                            await loadMyProducts();
                          }
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          "Add Product",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFC2410C),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Mini badge on card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              "${myProducts.length} Listed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // FARM STATS OVERVIEW STRIP
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _farmMiniStatCard(
                    icon: Icons.inventory_2_rounded,
                    label: "Crops",
                    value: "${myProducts.length}",
                    accentColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _farmMiniStatCard(
                    icon: Icons.local_shipping_rounded,
                    label: "Orders",
                    value: "${farmerOrders.length}",
                    accentColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _farmMiniStatCard(
                    icon: Icons.psychology_rounded,
                    label: "AI Tools",
                    value: "Online",
                    accentColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ==================================================
            // QUICK ACTIONS (2x2 GRID)
            // ==================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  "Farm tools",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: farmerActionCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: "Add Product",
                    subtitle: "Sell your products",
                    color: const Color(0xFF059669),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddProductScreen(),
                        ),
                      );

                      if (result == true) {
                        await loadMyProducts();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: farmerActionCard(
                    icon: Icons.inventory_2_rounded,
                    title: "My Products",
                    subtitle: "Manage products",
                    color: const Color(0xFFEA580C),
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: farmerActionCard(
                    icon: Icons.local_mall_rounded,
                    title: "Orders",
                    subtitle: "Customer orders",
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: farmerActionCard(
                    icon: Icons.person_rounded,
                    title: "Profile",
                    subtitle: "Manage account",
                    color: const Color(0xFF4F46E5),
                    onTap: () {
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // AGRII AI FARMING TOOLS
            // ==================================================
            const Text(
              "Agrii AI Farming Tools 🌾",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 14),

            toolCard(
              icon: Icons.eco_rounded,
              title: "Crop Advisor",
              description: "Get smart crop & fertilizer recommendations based on soil & climate.",
              color: const Color(0xFF059669),
              badge: "AI ADVISOR",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropAdvisorScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            toolCard(
              icon: Icons.psychology_rounded,
              title: "Agrii AI Chatbot",
              description: "Ask Agrii AI anything about pest control, weather & current market prices.",
              color: const Color(0xFF7C3AED),
              badge: "24/7 COPILOT",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            toolCard(
              icon: Icons.agriculture_rounded,
              title: "Agri Resources & Materials",
              description: "Manage and trade your farm equipment, organic fertilizers & seeds.",
              color: const Color(0xFFEA580C),
              badge: "MARKET",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerAgriResourcesScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // ==================================================
            // AGRII AI ASSISTANT INTERACTIVE PROMPT
            // ==================================================
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9A3412),
                      Color(0xFFEA580C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Color(0xFFEA580C),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Agrii AI Assistant",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Ask me anything about your farm, pests or crops.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // FARMER ACCOUNT SUMMARY
            // ==================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFFEA580C),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Verified Farmer Account",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          farmerEmail.isNotEmpty ? farmerEmail : "Active grower membership",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                label: const Text(
                  "Logout from Farm Console",
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _farmMiniStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PRODUCTS PAGE
  // ==========================================================

  Widget buildProducts() {
    return SafeArea(
      child: Column(
        children: [
          pageHeader(
            "My Products",
            subtitle: "Manage your listed farm crops & pricing",
            action: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
                if (result == true) {
                  await loadMyProducts();
                }
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                "Add Crop",
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFC2410C),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                    ),
                  )
                : myProducts.isEmpty
                ? _emptyProductsView()
                : RefreshIndicator(
                    color: const Color(0xFFEA580C),
                    onRefresh: loadMyProducts,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: myProducts.length,
                      itemBuilder: (context, index) {
                        final product = myProducts[index];
                        return _farmerProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyProductsView() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEA580C).withValues(alpha: 0.12),
                    const Color(0xFFD97706).withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: Color(0xFFC2410C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Crops Listed Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "List your freshly harvested vegetables, fruits and grains to start selling directly to consumers.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
                if (result == true) {
                  await loadMyProducts();
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                "Add First Product",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // ==========================================================
  // FARMER PRODUCT CARD
  // ==========================================================

  Widget _farmerProductCard(Map<String, dynamic> product) {
    final String status = product["approvalStatus"]?.toString() ?? "pending";
    final String rawImage = product["image"]?.toString() ?? "";
    final String imageUrl = rawImage.isNotEmpty
        ? (rawImage.startsWith("http") ? rawImage : "${ApiConstants.imageBaseUrl}$rawImage")
        : "";

    Color statusColor = const Color(0xFFD97706);
    Color statusBg = const Color(0xFFFEF3C7);
    IconData statusIcon = Icons.schedule_rounded;

    if (status.toLowerCase() == "approved") {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFECFDF5);
      statusIcon = Icons.check_circle_rounded;
    } else if (status.toLowerCase() == "rejected") {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusIcon = Icons.cancel_rounded;
    }

    final String name = product["name"]?.toString() ?? "Farm Produce";
    final String category = product["category"]?.toString() ?? "General";
    final dynamic price = product["price"] ?? 0;
    final dynamic quantity = product["quantity"] ?? 0;
    final String unit = product["unit"]?.toString() ?? "Kg";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.eco_rounded,
                            color: Color(0xFF059669),
                            size: 38,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF059669),
                          size: 38,
                        ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Category and Quantity Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.category_rounded, size: 12, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.scale_rounded, size: 12, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  "$quantity $unit",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          const Text(
                            "Price: ",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            "₹$price",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                          Text(
                            " / $unit",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (status.toLowerCase() == "rejected" && product["rejectionReason"] != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Rejection Reason: ${product["rejectionReason"]}",
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductScreen(product: product),
                      ),
                    );
                    if (result == true) {
                      await loadMyProducts();
                    }
                  },
                  icon: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF0284C7)),
                  label: const Text(
                    "Edit Crop",
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBAE6FD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => deleteProduct(product["_id"].toString()),
                  icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFDC2626)),
                  label: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
  // ORDERS PAGE
  // ==========================================================

  Widget buildOrders() {
    return SafeArea(
      child: Column(
        children: [
          pageHeader(
            "Customer Orders",
            subtitle: "Review & manage real-time buyer orders",
            action: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: "Refresh Orders",
                onPressed: loadFarmerOrders,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoadingOrders
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                    ),
                  )
                : farmerOrders.isEmpty
                ? _emptyOrdersView()
                : RefreshIndicator(
                    color: const Color(0xFFEA580C),
                    onRefresh: loadFarmerOrders,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: farmerOrders.length,
                      itemBuilder: (context, index) {
                        final order = farmerOrders[index];
                        return _farmerOrderCard(order);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyOrdersView() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.12),
                    const Color(0xFF059669).withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 46,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Customer Orders Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Incoming orders placed by consumers from the marketplace will appear here for processing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: loadFarmerOrders,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                "Check Orders",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // ==========================================================
  // FARMER ORDER CARD
  // ==========================================================

  Widget _farmerOrderCard(Map<String, dynamic> order) {
    final String status = order["status"]?.toString() ?? "Pending";
    final Map<String, dynamic> product = order["product"] is Map
        ? Map<String, dynamic>.from(order["product"])
        : {};
    final Map<String, dynamic> buyer = order["user"] is Map
        ? Map<String, dynamic>.from(order["user"])
        : {};

    final String rawImage = product["image"]?.toString() ?? "";
    final String imageUrl = rawImage.isNotEmpty
        ? (rawImage.startsWith("http") ? rawImage : "${ApiConstants.imageBaseUrl}$rawImage")
        : "";

    final String productName = product["name"]?.toString() ??
        order["productName"]?.toString() ??
        "Farm Produce";

    final String buyerName = order["buyerName"]?.toString() ??
        buyer["name"]?.toString() ??
        "Customer";

    final String buyerPhone = order["buyerPhone"]?.toString() ?? order["phone"]?.toString() ?? "N/A";
    final String deliveryAddress = order["deliveryAddress"]?.toString() ?? "N/A";

    final double totalAmount = num.tryParse(order["totalAmount"]?.toString() ?? "0")?.toDouble() ?? 0.0;
    final String orderId = order["_id"]?.toString() ?? "";
    final String shortOrderId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.eco_rounded,
                            color: Color(0xFF059669),
                            size: 38,
                          ),
                        )
                      : const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF059669),
                          size: 38,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Order #$shortOrderId",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          _statusChip(status),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Buyer details box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  _orderDetailRow(Icons.person_outline_rounded, "Buyer", buyerName),
                  const SizedBox(height: 4),
                  _orderDetailRow(Icons.phone_outlined, "Phone", buyerPhone),
                  const SizedBox(height: 4),
                  _orderDetailRow(Icons.location_on_outlined, "Address", deliveryAddress),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Total amount & Status controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Total: ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "₹${totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),

                if (status.toLowerCase() == "pending")
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => rejectOrder(orderId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => acceptOrder(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                if (status.toLowerCase() == "accepted" ||
                    status.toLowerCase() == "processing" ||
                    status.toLowerCase() == "shipped" ||
                    status.toLowerCase() == "delivered")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status.toLowerCase(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF475569)),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        items: ["accepted", "processing", "shipped", "delivered"].map((s) {
                          String label = s.toUpperCase();
                          if (s == "accepted") label = "PACKED";
                          if (s == "processing") label = "SHIPPED";
                          if (s == "shipped") label = "OUT FOR DELIVERY";

                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            updateOrderStatus(orderId, val);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        SizedBox(
          width: 65,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS CHIP
  // ==========================================================

  Widget _statusChip(String status) {
    Color textColor = const Color(0xFFD97706);
    Color bgColor = const Color(0xFFFEF3C7);
    IconData icon = Icons.schedule_rounded;

    final String s = status.toLowerCase();
    if (s == "delivered") {
      textColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.done_all_rounded;
    } else if (s == "accepted" || s == "approved" || s == "confirmed") {
      textColor = const Color(0xFF059669);
      bgColor = const Color(0xFFECFDF5);
      icon = Icons.check_circle_rounded;
    } else if (s == "cancelled" || s == "rejected") {
      textColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
      icon = Icons.cancel_rounded;
    } else if (s == "shipped" || s == "processing" || s == "out_for_delivery") {
      textColor = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFF3E8FF);
      icon = Icons.local_shipping_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PROFILE PAGE
  // ==========================================================

  Widget buildProfile() {
    Uint8List? imageBytes;

    if (profileBase64 != null) {
      try {
        imageBytes = base64Decode(profileBase64!);
      } catch (e) {
        debugPrint("Error decoding profile pic: $e");
      }
    }

    return SafeArea(
      child: Column(
        children: [
          pageHeader(
            "Farmer Profile",
            subtitle: "Grower account, farm verification & settings",
            action: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                tooltip: "Log Out",
                onPressed: logout,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // --- HERO FARMER IDENTITY CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showProfileOptions,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFEA580C),
                                      Color(0xFFF59E0B),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x33EA580C),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: const Color(0xFFFFF7ED),
                                  backgroundImage: imageBytes != null
                                      ? MemoryImage(imageBytes)
                                      : null,
                                  child: imageBytes == null
                                      ? const Icon(
                                          Icons.agriculture_rounded,
                                          color: Color(0xFFEA580C),
                                          size: 50,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          farmerName.isEmpty ? "Agri Farmer" : farmerName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farmerEmail.isEmpty ? "No email provided" : farmerEmail,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: Color(0xFFEA580C)),
                              SizedBox(width: 6),
                              Text(
                                "🌱 Verified Farmer & Grower",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC2410C),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- FARM METRICS QUICK STRIP ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _farmerProfileMetric(
                            icon: Icons.inventory_2_rounded,
                            iconColor: const Color(0xFFEA580C),
                            iconBg: const Color(0xFFFFF7ED),
                            value: "${myProducts.length}",
                            label: "Live Crops",
                          ),
                        ),
                        Container(width: 1, height: 38, color: const Color(0xFFE2E8F0)),
                        Expanded(
                          child: _farmerProfileMetric(
                            icon: Icons.local_shipping_rounded,
                            iconColor: const Color(0xFFD97706),
                            iconBg: const Color(0xFFFEF3C7),
                            value: "${farmerOrders.length}",
                            label: "Orders",
                          ),
                        ),
                        Container(width: 1, height: 38, color: const Color(0xFFE2E8F0)),
                        Expanded(
                          child: _farmerProfileMetric(
                            icon: Icons.sensors_rounded,
                            iconColor: const Color(0xFF059669),
                            iconBg: const Color(0xFFECFDF5),
                            value: "Active",
                            label: "AI Store",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- EDIT PROFILE ACTION TILE ---
                  _farmerProfileItem(
                    icon: Icons.edit_note_rounded,
                    title: "Edit Profile Details",
                    subtitle: "Update grower name & avatar photo",
                    onTap: _showEditProfileDialog,
                  ),

                  const SizedBox(height: 20),

                  // --- SECTION HEADER: ACCOUNT DETAILS ---
                  Row(
                    children: const [
                      Icon(Icons.badge_outlined, size: 18, color: Color(0xFFEA580C)),
                      SizedBox(width: 8),
                      Text(
                        "Grower Information",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  profileInfoCard(
                    icon: Icons.person_rounded,
                    title: "Farmer Name",
                    value: farmerName.isEmpty ? "Not set" : farmerName,
                  ),

                  const SizedBox(height: 10),

                  profileInfoCard(
                    icon: Icons.mail_rounded,
                    title: "Email Address",
                    value: farmerEmail.isEmpty ? "Not available" : farmerEmail,
                  ),

                  const SizedBox(height: 10),

                  profileInfoCard(
                    icon: Icons.agriculture_rounded,
                    title: "Account Designation",
                    value: "Registered Farm Producer",
                  ),

                  if (userId != null && userId!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    profileInfoCard(
                      icon: Icons.fingerprint_rounded,
                      title: "Farmer Identifier",
                      value: userId!.length > 12
                          ? "${userId!.substring(0, 12).toUpperCase()}..."
                          : userId!.toUpperCase(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // --- LOGOUT BUTTON ---
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        "Log Out Account",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PROFILE ITEM & HELPERS
  // ==========================================================

  Widget _farmerProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFEA580C), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _farmerProfileMetric({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: farmerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_note_rounded, color: Color(0xFFEA580C), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              "Edit Profile",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Grower / Farmer Name",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter your full name",
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFFEA580C), size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _showProfileOptions();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Color(0xFFEA580C), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Change Profile Photo",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFEA580C)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("name", newName);
                if (mounted) {
                  setState(() {
                    farmerName = newName;
                  });
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _showSuccess("Profile name updated successfully!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAGE HEADER
  // ==========================================================

  Widget pageHeader(String title, {String? subtitle, Widget? action}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9A3412), // Deep Terracotta
            Color(0xFFC2410C), // Warm Ochre
            Color(0xFFEA580C), // Sunrise Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2AEA580C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  // ==========================================================
  // FARMER ACTION CARD
  // ==========================================================

  Widget farmerActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TOOL CARD
  // ==========================================================

  Widget toolCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PROFILE INFO CARD
  // ==========================================================

  Widget profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFEA580C), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMING SOON
  // ==========================================================

  void showComingSoon(String title) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title screen is ready to connect."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
