import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/theme/auth_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_components.dart';
import '../admin/admin_dashboard_screen.dart';
import '../farmer/farmer_home_screen.dart';
import '../register/register_screen.dart';
import '../user/user_dashboard.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialLoginType = 'User'});

  final String initialLoginType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late String loginType;
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = true;

  RoleThemeConfig get config => RoleThemeConfig.fromKey(loginType);

  @override
  void initState() {
    super.initState();
    final String type = widget.initialLoginType.trim().toLowerCase();
    if (type == 'farmer') {
      loginType = 'Farmer';
    } else {
      loginType = 'User';
    }
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email_${loginType.toLowerCase()}');
      if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
        setState(() {
          emailController.text = savedEmail;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void changeLoginType(String type) {
    if (isLoading || loginType == type) return;
    setState(() {
      loginType = type;
      emailController.clear();
      passwordController.clear();
      obscurePassword = true;
    });
    _loadSavedCredentials();
  }

  Future<void> login() async {
    if (isLoading) return;

    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text;

    if (email.isEmpty) {
      AuthNotifier.showError(context, 'Please enter your email address.');
      return;
    }
    if (password.isEmpty) {
      AuthNotifier.showError(context, 'Please enter your password.');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email_${loginType.toLowerCase()}', email);
      }

      // Consumer & Farmer authentication
      final AuthResult authResult = await AuthService.loginAnyRole(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (!authResult.success) {
        setState(() => isLoading = false);
        AuthNotifier.showError(context, authResult.message);
        return;
      }

      final String? savedRole = await AuthService.getRole();
      if (!mounted) return;

      if (savedRole == null) {
        await AuthService.logout();
        if (!mounted) return;
        setState(() => isLoading = false);
        AuthNotifier.showError(context, 'Account role not detected.');
        return;
      }

      final String role = savedRole.toLowerCase();

      // Routing logic with validation
      if (role == 'admin') {
        AuthNotifier.showSuccess(context, 'Welcome to Central Command!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (r) => false,
        );
      } else if (role == 'user' && loginType == 'User') {
        AuthNotifier.showSuccess(context, 'Welcome back to Agrii AI!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboard()),
          (r) => false,
        );
      } else if (role == 'farmer' && loginType == 'Farmer') {
        AuthNotifier.showSuccess(context, 'Welcome back, Farmer Partner!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
          (r) => false,
        );
      } else {
        await AuthService.logout();
        if (!mounted) return;
        setState(() => isLoading = false);
        String correctTab = role == 'farmer' ? 'Farmer' : 'Consumer';
        AuthNotifier.showError(
          context,
          'This account is registered as a $correctTab. Please switch to the $correctTab tab.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AuthNotifier.showError(context, 'Connection failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header with dynamic role gradient & floating emblem
            AuthHeroHeader(
              config: config,
              showBack: Navigator.canPop(context),
            ),

            // Content body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3-way Role Selector Bar
                  AuthRoleSelector(
                    activeRole: loginType,
                    onRoleChanged: changeLoginType,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 20),

                  // Dynamic Role Welcome Banner
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(loginType),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              config.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: config.lightTint,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: config.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                loginType.toUpperCase(),
                                style: TextStyle(
                                  color: config.primaryColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          config.subtitle,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main Elevated Form Card
                  AuthElevatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        AuthTextField(
                          controller: emailController,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          config: config,
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        AuthTextField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: obscurePassword,
                          onToggleObscure: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                          config: config,
                        ),

                        const SizedBox(height: 12),

                        // Options Row: Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: rememberMe,
                                    activeColor: config.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    onChanged: (val) {
                                      setState(() => rememberMe = val ?? true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResetPasswordScreen(type: loginType),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: config.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        AuthGradientButton(
                          text: config.buttonText,
                          onPressed: login,
                          isLoading: isLoading,
                          config: config,
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer Section based on Role
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(
                                  registerType: loginType,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: config.lightTint,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: config.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Register as ${loginType == 'User' ? 'Consumer' : 'Farmer'}',
                              style: TextStyle(
                                color: config.primaryColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
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
          ],
        ),
      ),
    );
  }
}
