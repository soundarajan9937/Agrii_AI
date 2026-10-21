import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/profile_service.dart';

import '../../widgets/profile_header.dart';
import '../../widgets/profile_info_card.dart';
import '../../widgets/profile_menu.dart';

import '../marketplace/my_products_screen.dart';

import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'help_screen.dart';
import 'privacy_policy_screen.dart';
import 'saved_reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    setState(() {
      isLoading = true;
    });

    user = await ProfileService.getProfile();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                name: user?.name ?? "Farmer",
                email: user?.email ?? "farmer@gmail.com",
                phone: user?.phone ?? "",
                imagePath: user?.profileImage ?? "",
                onEditPhoto: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Change profile photo")),
                  );
                },
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),

                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Farm Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ProfileInfoCard(
                      icon: Icons.agriculture,
                      title: "Farm Name",
                      value: user?.farmName ?? "",
                    ),

                    ProfileInfoCard(
                      icon: Icons.location_on,
                      title: "Farm Location",
                      value: user?.farmLocation ?? "",
                    ),

                    ProfileInfoCard(
                      icon: Icons.square_foot,
                      title: "Farm Size",
                      value: user?.farmSize ?? "",
                    ),

                    ProfileInfoCard(
                      icon: Icons.eco,
                      title: "Main Crop",
                      value: user?.mainCrop ?? "",
                    ),

                    ProfileInfoCard(
                      icon: Icons.grass,
                      title: "Soil Type",
                      value: user?.soilType ?? "",
                    ),

                    const SizedBox(height: 25),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ProfileMenu(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );

                        loadUser();
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.settings,
                      title: "Settings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.inventory_2,
                      title: "My Products",
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyProductsScreen(),
                          ),
                        );

                        loadUser();
                      },
                    ),
                    ProfileMenu(
                      icon: Icons.language,
                      title: "Language",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Language feature coming soon"),
                          ),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.history,
                      title: "Saved Crop Reports",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedReportsScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.notifications,
                      title: "Notifications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.help,
                      title: "Help & Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HelpScreen()),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.privacy_tip,
                      title: "Privacy Policy",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenu(
                      icon: Icons.info,
                      title: "About Agrii Assist AI",
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Agrii Assist AI",
                          applicationVersion: "Version 1.0.0",
                          applicationLegalese: "© 2026 Agrii Assist AI",
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "Agrii Assist AI is an AI-powered smart farming application that helps farmers detect crop diseases, receive AI recommendations, monitor weather, and improve agricultural productivity.",
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                "Are you sure you want to logout?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      244,
                                      143,
                                      54,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Logged out successfully",
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Logout"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
