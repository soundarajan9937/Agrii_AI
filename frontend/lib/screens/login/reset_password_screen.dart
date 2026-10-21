import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String type; // 'User' or 'Farmer'
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

  Color get primaryColor => widget.type == 'Farmer' ? const Color(0xFFF57C00) : const Color(0xFF1976D2);

  Future<void> handleReset() async {
    final email = emailController.text.trim();
    final hint = hintController.text.trim();
    final password = newPasswordController.text;

    if (email.isEmpty || hint.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.resetPassword(
      email: email,
      recoveryHint: hint,
      newPassword: password,
    );

    setState(() => isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark theme as per image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: primaryColor), onPressed: () => Navigator.pop(context))
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Reset icon matching the theme
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Icon(Icons.lock_reset, size: 60, color: primaryColor),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RESET PASSWORD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    )
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Verify your account using your unique Recover Hint.",
                    style: TextStyle(color: Colors.white70, fontSize: 13)
                  ),
                  const SizedBox(height: 30),
                  _buildField("Registered Email", Icons.email_outlined, emailController),
                  const SizedBox(height: 15),
                  _buildField("Recover Hint", Icons.help_outline, hintController),
                  const SizedBox(height: 15),
                  _buildField("New Password", Icons.lock_outline, newPasswordController, isPassword: true),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: isLoading
                        ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("RESET PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white24),
          onPressed: () => setState(() => obscurePassword = !obscurePassword)
        ) : null,
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor.withAlpha(150))),
      ),
    );
  }
}
