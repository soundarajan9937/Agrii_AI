import 'package:flutter/material.dart';

// ==========================================================
// AI FEATURES
// ==========================================================

import 'package:frontend/screens/chatbot/chatbot_screen.dart';
import 'package:frontend/screens/crop_advisor/crop_advisor_screen.dart';
import 'package:frontend/screens/marketplace/farmer_upload_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';

// ==========================================================
// FARMER DASHBOARD
// ==========================================================

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  // ==========================================================
  // NAVIGATION HELPER
  // ==========================================================

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              _openScreen(context, const ProfileScreen());
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // WELCOME CARD
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.white,

                          child: Icon(
                            Icons.agriculture,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),

                        SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            'Welcome Farmer 🌱',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Text(
                      'Manage your farm, products, orders and AI farming tools.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // BUSINESS STATISTICS
              // ==================================================
              const Text(
                'Farm Overview',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.inventory_2,
                      title: 'Products',
                      value: '8',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.shopping_bag,
                      title: 'Orders',
                      value: '12',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.currency_rupee,
                      title: 'Earnings',
                      value: '₹18,500',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      value: '4',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // AI FARMING TOOLS
              // ==================================================
              const Text(
                'AI Farming Tools',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Use smart AI tools to improve your farming decisions.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,

                crossAxisSpacing: 14,

                mainAxisSpacing: 14,

                childAspectRatio: 1.05,

                children: [
                  // ==================================================
                  // CROP ADVISOR
                  // ==================================================
                  _featureCard(
                    context: context,
                    icon: Icons.eco,
                    title: 'Crop Advisor',
                    subtitle: 'Get smart crop recommendations',
                    color: Colors.green,
                    onTap: () {
                      _openScreen(context, const CropAdvisorScreen());
                    },
                  ),

                  // ==================================================
                  // AI CHATBOT
                  // ==================================================
                  _featureCard(
                    context: context,
                    icon: Icons.smart_toy,
                    title: 'AI Chatbot',
                    subtitle: 'Ask your farming questions',
                    color: Colors.orange,
                    onTap: () {
                      _openScreen(context, const ChatbotScreen());
                    },
                  ),

                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // MARKETPLACE
              // ==================================================
              const Text(
                'Marketplace',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sell your agricultural products through the marketplace.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 15),

              _menuCard(
                context,
                icon: Icons.cloud_upload,
                title: 'Farmer Upload',
                subtitle:
                    'Upload your agricultural products for admin approval',
                iconColor: Colors.orange,
                onTap: () {
                  _openScreen(context, const FarmerUploadScreen());
                },
              ),

              const SizedBox(height: 12),

              _menuCard(
                context,
                icon: Icons.inventory_2,
                title: 'My Products',
                subtitle: 'View and manage your uploaded agricultural products',
                iconColor: Colors.deepOrange,
                onTap: () {
                  _showComingSoon(context, 'My Products');
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // BUSINESS MANAGEMENT
              // ==================================================
              const Text(
                'Business Management',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // ORDERS
              // ==================================================
              _menuCard(
                context,
                icon: Icons.shopping_cart,
                title: 'Seller Orders',
                subtitle: 'View orders received from customers',
                iconColor: Colors.blue,
                onTap: () {
                  _openScreen(context, const SellerOrdersPage());
                },
              ),

              // ==================================================
              // EARNINGS
              // ==================================================
              _menuCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'My Earnings',
                subtitle: 'View your sales and total earnings',
                iconColor: Colors.teal,
                onTap: () {
                  _openScreen(context, const EarningsPage());
                },
              ),

              // ==================================================
              // DELIVERY
              // ==================================================
              _menuCard(
                context,
                icon: Icons.local_shipping,
                title: 'Delivery Status',
                subtitle: 'Manage customer deliveries and order status',
                iconColor: Colors.deepOrange,
                onTap: () {
                  _openScreen(context, const DeliveryStatusPage());
                },
              ),

              // ==================================================
              // PROFILE
              // ==================================================
              _menuCard(
                context,
                icon: Icons.person,
                title: 'Farmer Profile',
                subtitle: 'View and update your farmer account details',
                iconColor: Colors.indigo,
                onTap: () {
                  _openScreen(context, const ProfileScreen());
                },
              ),

              const SizedBox(height: 25),

              // ==================================================
              // INFORMATION CARD
              // ==================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(17),

                decoration: BoxDecoration(
                  color: Colors.orange.shade100,

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(color: Colors.orange.shade200),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 28),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Products uploaded by you will appear in the marketplace only after admin approval.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        selectedItemColor: Colors.orange,

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          switch (index) {
            // HOME
            case 0:
              break;

            // CHATBOT
            case 1:
              _openScreen(context, const ChatbotScreen());
              break;

            // UPLOAD
            case 2:
              _openScreen(context, const FarmerUploadScreen());
              break;

            // PROFILE
            case 3:
              _openScreen(context, const ProfileScreen());
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Chat'),

          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  static Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: Colors.orange, size: 28),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // ==========================================================
  // AI FEATURE CARD
  // ==========================================================

  static Widget _featureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,

      shadowColor: Colors.black12,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              CircleAvatar(
                radius: 29,

                backgroundColor: color.withValues(alpha: 0.15),

                child: Icon(icon, color: color, size: 32),
              ),

              const SizedBox(height: 11),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                textAlign: TextAlign.center,

                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MENU CARD
  // ==========================================================

  static Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),

        leading: CircleAvatar(
          radius: 24,

          backgroundColor: iconColor.withValues(alpha: 0.13),

          child: Icon(icon, color: iconColor),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.grey,
        ),

        onTap: onTap,
      ),
    );
  }

  // ==========================================================
  // COMING SOON
  // ==========================================================

  static void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title screen is ready to be connected.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ==========================================================
// TEMPORARY SELLER ORDERS PAGE
// ==========================================================

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleFarmerPage(title: 'Seller Orders', icon: Icons.shopping_cart);
  }
}

// ==========================================================
// TEMPORARY EARNINGS PAGE
// ==========================================================

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleFarmerPage(
      title: 'My Earnings',
      icon: Icons.account_balance_wallet,
    );
  }
}

// ==========================================================
// TEMPORARY DELIVERY PAGE
// ==========================================================

class DeliveryStatusPage extends StatelessWidget {
  const DeliveryStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleFarmerPage(
      title: 'Delivery Status',
      icon: Icons.local_shipping,
    );
  }
}

// ==========================================================
// TEMPORARY SIMPLE PAGE
// ==========================================================

class _SimpleFarmerPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SimpleFarmerPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 70, color: Colors.orange),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'This screen is ready to be connected.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
