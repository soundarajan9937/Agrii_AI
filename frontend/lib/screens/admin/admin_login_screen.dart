import 'package:flutter/material.dart';
import '../../core/constants/theme/auth_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_components.dart';
import '../login/login_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = true;

  final RoleThemeConfig config = RoleThemeConfig.admin;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      AuthNotifier.showError(context, "Enter your administrator email");
      return;
    }
    if (password.isEmpty) {
      AuthNotifier.showError(context, "Enter your administrator password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final AuthResult result = await AuthService.loginAdmin(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result.success) {
        AuthNotifier.showSuccess(context, "Admin authentication successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        AuthNotifier.showError(context, result.message);
      }
    } catch (e) {
      if (!mounted) return;
      AuthNotifier.showError(context, "Unable to connect to security server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark Obsidian Hero Header with Neon Lime Shield Badge
            AuthHeroHeader(
              config: config,
              onBack: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(initialLoginType: 'User'),
                    ),
                  );
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle with Electric Lime Pill
                  Row(
                    children: [
                      const Text(
                        "Admin Console",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AdminTheme.limeChip(
                        "ROOT ACCESS",
                        icon: Icons.verified_user_rounded,
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in with your master credentials to supervise operations, approve listings, and view real-time platform metrics.",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AdminTheme.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Elevated Dark Glass Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: AdminTheme.cardDecoration(
                      borderColor: AdminTheme.limeBorder,
                      hasGlow: true,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Admin Email
                        AuthTextField(
                          controller: emailController,
                          label: "Administrator Email",
                          hint: "admin@agrii.com",
                          prefixIcon: Icons.admin_panel_settings_outlined,
                          keyboardType: TextInputType.emailAddress,
                          config: config,
                        ),

                        const SizedBox(height: 18),

                        // Password
                        AuthTextField(
                          controller: passwordController,
                          label: "Master Password",
                          hint: "Enter security key",
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: obscurePassword,
                          onToggleObscure: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                          config: config,
                        ),

                        const SizedBox(height: 16),

                        // Security Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTheme.limeTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminTheme.limeBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.security_rounded,
                                size: 16,
                                color: AdminTheme.lime,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Protected by TLS 1.3 encryption & RBAC controls",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AdminTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Button in Solid Electric Lime (#00FF00)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : login,
                            icon: isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.shield_rounded, color: Colors.black, size: 20),
                            label: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text(
                                    "Authenticate & Enter",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.lime,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              shadowColor: AdminTheme.limeGlow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Return to User / Farmer Login
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(initialLoginType: 'User'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.swap_horiz_rounded,
                        size: 18,
                        color: AdminTheme.lime,
                      ),
                      label: const Text(
                        "Switch to Consumer / Farmer Portal",
                        style: TextStyle(
                          color: AdminTheme.lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
