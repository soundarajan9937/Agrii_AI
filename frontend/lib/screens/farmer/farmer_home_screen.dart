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
import '../agri_resources/agri_resources_screen.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),

          const Text(
            "Profile Picture",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.orange),
            title: const Text("Set Profile Picture"),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),

          if (profileBase64 != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove Profile Picture"),
              onTap: () {
                Navigator.pop(context);
                _removeImage();
              },
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ==========================================================
  // SUCCESS MESSAGE
  // ==========================================================

  void _showSuccess(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
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
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
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
      backgroundColor: const Color(0xFFFDF7F2),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.orange,
                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes)
                      : null,
                  child: imageBytes == null
                      ? const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 30,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back!",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        farmerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsListScreen()),
                        );
                        _loadUnreadCount();
                      },
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unreadNotifications > 9 ? "9+" : "$unreadNotifications",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // FARMER WELCOME CARD
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.agriculture, color: Colors.white, size: 45),
                  const SizedBox(height: 12),
                  const Text(
                    "Farmer Dashboard 🌱",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage your farm products, orders and activities from one place.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: farmerActionCard(
                    icon: Icons.add_box,
                    title: "Add Product",
                    subtitle: "Sell your products",
                    color: Colors.green,
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
                    icon: Icons.inventory,
                    title: "My Products",
                    subtitle: "Manage products",
                    color: Colors.orange,
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
                    icon: Icons.shopping_bag,
                    title: "Orders",
                    subtitle: "Customer orders",
                    color: Colors.blue,
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
                    icon: Icons.person,
                    title: "Profile",
                    subtitle: "Manage account",
                    color: Colors.indigo,
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

            const Text(
              "Agrii AI Farming Tools",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            toolCard(
              icon: Icons.eco,
              title: "Crop Advisor",
              description: "Get smart recommendations.",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropAdvisorScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            toolCard(
              icon: Icons.smart_toy,
              title: "Agrii AI Chatbot",
              description: "Ask Agrii AI anything.",
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            toolCard(
              icon: Icons.category,
              title: "Agri Resources & Materials",
              description: "Manage your farm materials.",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerAgriResourcesScreen()),
                );
              },
            ),

            const SizedBox(height: 25),

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
                    colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.orange,
                        size: 35,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Agrii AI Assistant",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Ask me anything about farming.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.orange,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Farmer Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          farmerEmail,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
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
          pageHeader("My Products"),
          Expanded(
            child: isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : myProducts.isEmpty
                ? _emptyProductsView()
                : RefreshIndicator(
                    onRefresh: loadMyProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
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
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0x1FFF9800),
              child: Icon(Icons.inventory_2, size: 45, color: Colors.orange),
            ),

            const SizedBox(height: 20),

            const Text(
              "Manage Your Products",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Add products that you want to sell.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

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
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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

    final String imageUrl = product["image"]?.toString() ?? "";

    Color statusColor = Colors.orange;

    if (status.toLowerCase() == "approved") {
      statusColor = Colors.green;
    }

    if (status.toLowerCase() == "rejected") {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          ApiConstants.imageBaseUrl + imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.inventory_2,
                                color: Colors.orange,
                                size: 40,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.orange,
                          size: 40,
                        ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product["name"] ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Category: ${product["category"]}",
                        style: const TextStyle(color: Colors.black87),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Price: ₹${product["price"]}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Quantity: ${product["quantity"]}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (status.toLowerCase() == "rejected" &&
                product["rejectionReason"] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Reason: ${product["rejectionReason"]}",
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
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
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),

                const SizedBox(width: 15),

                TextButton.icon(
                  onPressed: () => deleteProduct(product["_id"].toString()),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
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
          pageHeader("Customer Orders"),

          Expanded(
            child: isLoadingOrders
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : farmerOrders.isEmpty
                ? _emptyOrdersView()
                : RefreshIndicator(
                    onRefresh: loadFarmerOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Color(0x1FFF9800),
            child: Icon(Icons.shopping_bag, size: 45, color: Colors.orange),
          ),

          SizedBox(height: 20),

          Text(
            "No Orders Yet",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text(
            "Customer orders will appear here.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
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

    final String imageUrl = product["image"]?.toString() ?? "";

    final String productName =
        product["name"]?.toString() ??
        order["productName"]?.toString() ??
        "Unknown Product";

    final String buyerName =
        order["buyerName"]?.toString() ??
        buyer["name"]?.toString() ??
        "Unknown Buyer";

    final String buyerPhone =
        order["buyerPhone"]?.toString() ?? order["phone"]?.toString() ?? "N/A";

    final double totalAmount =
        num.tryParse(order["totalAmount"]?.toString() ?? "0")?.toDouble() ??
        0.0;

    final String orderId = order["_id"]?.toString() ?? "";

    final String shortOrderId = orderId.length > 6
        ? orderId.substring(orderId.length - 6)
        : orderId;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          ApiConstants.imageBaseUrl + imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.inventory_2,
                                color: Colors.orange,
                                size: 35,
                              ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.orange,
                          size: 35,
                        ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Order #$shortOrderId",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          _statusChip(status),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Buyer: $buyerName",
                        style: const TextStyle(fontSize: 14),
                      ),

                      Text(
                        "Phone: $buyerPhone",
                        style: const TextStyle(fontSize: 14),
                      ),

                      Text(
                        "Address: ${order["deliveryAddress"] ?? "N/A"}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ₹${totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                if (status.toLowerCase() == "pending")
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => rejectOrder(orderId),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text("Reject"),
                      ),

                      const SizedBox(width: 8),

                      ElevatedButton(
                        onPressed: () => acceptOrder(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text("Accept"),
                      ),
                    ],
                  ),

                if (status.toLowerCase() == "accepted" ||
                    status.toLowerCase() == "processing" ||
                    status.toLowerCase() == "shipped")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: status.toLowerCase(),
                      underline: const SizedBox(),
                      items: ["accepted", "processing", "shipped", "delivered"]
                          .map((s) {
                            String label = s.toUpperCase();

                            if (s == "accepted") {
                              label = "PACKED";
                            }

                            if (s == "processing") {
                              label = "SHIPPED";
                            }

                            if (s == "shipped") {
                              label = "OUT FOR DELIVERY";
                            }

                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          updateOrderStatus(orderId, val);
                        }
                      },
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
  // STATUS CHIP
  // ==========================================================

  Widget _statusChip(String status) {
    Color color = Colors.orange;

    final String s = status.toLowerCase();

    if (s == "delivered" || s == "accepted") {
      color = Colors.green;
    }

    if (s == "cancelled" || s == "rejected") {
      color = Colors.red;
    }

    if (s == "shipped" || s == "processing") {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _showProfileOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange,
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : null,
                    child: imageBytes == null
                        ? const Icon(
                            Icons.agriculture,
                            color: Colors.white,
                            size: 55,
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              farmerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(farmerEmail, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            _farmerProfileItem(
              Icons.edit,
              "Edit Profile",
              onTap: () {
                _showSuccess("Edit Profile functionality ready.");
              },
            ),

            const SizedBox(height: 12),

            profileInfoCard(
              icon: Icons.person,
              title: "Name",
              value: farmerName,
            ),

            const SizedBox(height: 12),

            profileInfoCard(
              icon: Icons.email,
              title: "Email",
              value: farmerEmail.isEmpty ? "Not available" : farmerEmail,
            ),

            const SizedBox(height: 12),

            profileInfoCard(
              icon: Icons.agriculture,
              title: "Account Type",
              value: "Farmer",
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PROFILE ITEM
  // ==========================================================

  Widget _farmerProfileItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ==========================================================
  // PAGE HEADER
  // ==========================================================

  Widget pageHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 27),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 28),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withValues(alpha: 0.12),
            child: Icon(icon, color: Colors.orange),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
