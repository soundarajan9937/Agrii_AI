import 'package:flutter/material.dart';
import '../../core/constants/theme/auth_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_components.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String type; // 'User' or 'Farmer' or 'Admin'
  const ResetPasswordScreen({super.key, required this.type});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController hintController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  RoleThemeConfig get config => RoleThemeConfig.fromKey(widget.type);

  @override
  void dispose() {
    emailController.dispose();
    hintController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleReset() async {
    final email = emailController.text.trim();
    final hint = hintController.text.trim();
    final password = newPasswordController.text;

    if (email.isEmpty) {
      AuthNotifier.showError(context, 'Please enter your registered email');
      return;
    }
    if (hint.isEmpty) {
      AuthNotifier.showError(context, 'Please enter your account recovery hint');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      AuthNotifier.showError(context, 'New password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.resetPassword(
        email: email,
        recoveryHint: hint,
        newPassword: password,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result.success) {
        AuthNotifier.showSuccess(context, result.message);
        Navigator.pop(context);
      } else {
        AuthNotifier.showError(context, result.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AuthNotifier.showError(context, 'Reset failed. Check server connectivity.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            AuthHeroHeader(
              config: config,
              onBack: () => Navigator.pop(context),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  Row(
                    children: [
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: config.lightTint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: config.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.type.toUpperCase(),
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
                  const Text(
                    "Verify your identity with your registered secret recovery hint to securely reset your account credentials.",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF64748B),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Form Card
                  AuthElevatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        AuthTextField(
                          controller: emailController,
                          label: "Registered Email",
                          hint: "you@example.com",
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          config: config,
                        ),

                        const SizedBox(height: 18),

                        // Recovery Hint
                        AuthTextField(
                          controller: hintController,
                          label: "Secret Recovery Hint",
                          hint: "e.g. Favorite crop, childhood pet",
                          prefixIcon: Icons.help_outline_rounded,
                          config: config,
                        ),

                        const SizedBox(height: 18),

                        // New Password
                        AuthTextField(
                          controller: newPasswordController,
                          label: "New Password",
                          hint: "Min. 6 characters",
                          prefixIcon: Icons.lock_reset_rounded,
                          isPassword: true,
                          obscureText: obscurePassword,
                          onToggleObscure: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                          config: config,
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        AuthGradientButton(
                          text: "Update Password",
                          onPressed: handleReset,
                          isLoading: isLoading,
                          config: config,
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 17,
                        color: config.primaryColor,
                      ),
                      label: Text(
                        "Back to ${widget.type} Login",
                        style: TextStyle(
                          color: config.primaryColor,
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
