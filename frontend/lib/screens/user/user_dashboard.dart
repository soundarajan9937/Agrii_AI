import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../marketplace/my_orders_screen.dart';
import '../agri_resources/agri_resources_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const UserHomeTab(),
      const MarketplaceScreen(),
      const MyOrdersScreen(),
      const UserProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "Marketplace"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class UserHomeTab extends StatefulWidget {
  const UserHomeTab({super.key});

  @override
  State<UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<UserHomeTab> {
  String userName = "User";
  String? profileBase64;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString("userId");
    setState(() {
      userName = prefs.getString("name") ?? "User";
      if (userId != null) {
        profileBase64 = prefs.getString("profile_pic_data_$userId");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1976D2),
                  backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                  child: imageBytes == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome back!", style: TextStyle(fontSize: 15, color: Colors.grey)),
                      const SizedBox(height: 3),
                      Text(userName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.agriculture, color: Colors.white, size: 42),
                  SizedBox(height: 12),
                  Text("Agrii Marketplace 🌱", style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Buy fresh agricultural products directly from farmers.", style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text("Our Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _serviceCard(
              Icons.eco,
              "Fresh Farm Products",
              "Direct from farmer to your home.",
              onTap: () {
                final parentState = context.findAncestorStateOfType<_UserDashboardState>();
                if (parentState != null) {
                  parentState.setState(() {
                    parentState._currentIndex = 1;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            _serviceCard(
              Icons.category,
              "Agri Resources & Materials",
              "Buy waste materials and tools from farmers.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgriResourcesScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _serviceCard(
              Icons.local_shipping,
              "Track Orders",
              "Track your delivery in real-time.",
              onTap: () {
                final parentState = context.findAncestorStateOfType<_UserDashboardState>();
                if (parentState != null) {
                  parentState.setState(() {
                    parentState._currentIndex = 2;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, String desc, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1), child: Icon(icon, color: const Color(0xFF1976D2))),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13))])),
            if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class UserProfileTab extends StatefulWidget {
  const UserProfileTab({super.key});

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  String name = "";
  String email = "";
  String? userId;
  String? profileBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId");
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";
      if (userId != null) {
        profileBase64 = prefs.getString("profile_pic_data_$userId");
      }
    });
  }

  Future<void> _pickImage() async {
    if (userId == null) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 75);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_pic_data_$userId", base64Image);
      setState(() {
        profileBase64 = base64Image;
      });
      _showSuccess("Profile picture updated!");
    }
  }

  Future<void> _removeImage() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("profile_pic_data_$userId");
    setState(() {
      profileBase64 = null;
    });
    _showSuccess("Profile picture removed");
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Profile Picture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1976D2)));
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (profileBase64 != null) {
      try {
        imageBytes = base64Decode(profileBase64!);
      } catch (e) {
        debugPrint("Error decoding bytes: $e");
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _showProfileOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF1976D2),
                    backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                    child: imageBytes == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 18, color: const Color(0xFF1976D2)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _profileItem(Icons.edit, "Edit Profile", onTap: () => _showSuccess("Edit Profile functionality ready.")),
                  const SizedBox(height: 12),
                  _infoCard(Icons.person, "Name", name),
                  const SizedBox(height: 12),
                  _infoCard(Icons.email, "Email", email),
                  const SizedBox(height: 12),
                  _infoCard(Icons.account_circle, "Account Type", "User"),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await AuthService.logout();
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1), child: Icon(icon, color: const Color(0xFF1976D2))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
