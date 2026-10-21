import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String registerType;

  const RegisterScreen({super.key, required this.registerType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController recoveryHintController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  bool get isFarmer => widget.registerType.trim().toLowerCase() == 'farmer';
  bool get isUser => widget.registerType.trim().toLowerCase() == 'user';

  Color get primaryColor => isFarmer ? const Color(0xFFFF9800) : const Color(0xFF1976D2);
  Color get lightColor => isFarmer ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD);
  IconData get registerIcon => isFarmer ? Icons.agriculture : Icons.person;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    farmNameController.dispose();
    farmLocationController.dispose();
    recoveryHintController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      showMessage('Passwords do not match.', error: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      AuthResult? authResult;
      if (isFarmer) {
        authResult = await AuthService.farmerRegister(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          password: passwordController.text,
          farmName: farmNameController.text.trim(),
          farmLocation: farmLocationController.text.trim(),
          recoveryHint: recoveryHintController.text.trim(),
        );
      } else {
        authResult = await AuthService.register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          password: passwordController.text,
          recoveryHint: recoveryHintController.text.trim(),
        );
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      if (authResult.success) {
        showMessage('${isFarmer ? 'Farmer' : 'User'} registration successful!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen(initialLoginType: isFarmer ? 'Farmer' : 'User')),
          (route) => false,
        );
      } else {
        showMessage(authResult.message, error: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage('Unable to connect to the server.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(backgroundColor: primaryColor, foregroundColor: Colors.white, centerTitle: true, title: Text(isFarmer ? 'Farmer Register' : 'User Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(radius: 55, backgroundColor: primaryColor, child: Icon(registerIcon, size: 60, color: Colors.white)),
                const SizedBox(height: 20),
                Text(isFarmer ? 'Create Farmer Account' : 'Create User Account', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                buildField(label: 'Full Name', icon: Icons.person_outline, controller: nameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                buildField(label: 'Email', icon: Icons.email_outlined, controller: emailController, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                buildField(label: 'Phone Number', icon: Icons.phone_outlined, controller: phoneController, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                if (isFarmer) ...[
                  buildField(label: 'Farm Name', icon: Icons.home_work_outlined, controller: farmNameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                  buildField(label: 'Farm Location', icon: Icons.location_on_outlined, controller: farmLocationController, validator: (v) => v!.isEmpty ? 'Required' : null),
                ],
                buildField(label: 'Recover Hint', icon: Icons.help_outline, controller: recoveryHintController, validator: (v) => v!.isEmpty ? 'Required for password reset' : null),
                buildField(label: 'Password', icon: Icons.lock_outline, controller: passwordController, obscureText: hidePassword, validator: (v) => v!.length < 6 ? 'Min 6 characters' : null, suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hidePassword = !hidePassword))),
                buildField(label: 'Confirm Password', icon: Icons.lock_reset_outlined, controller: confirmPasswordController, obscureText: hideConfirmPassword, validator: (v) => v != passwordController.text ? 'Not match' : null, textInputAction: TextInputAction.done, suffixIcon: IconButton(icon: Icon(hideConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: isLoading ? null : register, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Register', style: const TextStyle(fontSize: 18)))),
                TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(initialLoginType: isFarmer ? 'Farmer' : 'User'))), child: Text('Already have an account? Login', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField({required String label, required IconData icon, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator, TextInputAction textInputAction = TextInputAction.next}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller, keyboardType: keyboardType, obscureText: obscureText, validator: validator, textInputAction: textInputAction, enabled: !isLoading,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: primaryColor), suffixIcon: suffixIcon, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),
    );
  }
}
