import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../farmer/farmer_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/user_dashboard.dart';
import '../register/register_screen.dart';
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

  static const Color userColor = Color(0xFF1976D2);
  static const Color farmerColor = Color(0xFFF57C00);
  static const Color adminColor = Color(0xFF2E7D32);

  Color get primaryColor => loginType == 'Farmer' ? farmerColor : userColor;

  @override
  void initState() {
    super.initState();
    final String type = widget.initialLoginType.trim().toLowerCase();
    loginType = (type == 'farmer') ? 'Farmer' : 'User';
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
  }

  Future<void> login() async {
    if (isLoading) return;

    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text;

    if (email.isEmpty) { showMessage('Please enter your email.'); return; }
    if (password.isEmpty) { showMessage('Please enter your password.'); return; }

    setState(() => isLoading = true);

    try {
      final AuthResult authResult = await AuthService.loginAnyRole(email: email, password: password);
      if (!mounted) return;

      if (!authResult.success) {
        setState(() => isLoading = false);
        showMessage(authResult.message);
        return;
      }

      final String? savedRole = await AuthService.getRole();
      if (!mounted) return;

      if (savedRole == null) {
        await AuthService.logout();
        setState(() => isLoading = false);
        showMessage('Role not found.');
        return;
      }

      final String role = savedRole.toLowerCase();

      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()), (r) => false);
      } else if (role == 'user' && loginType == 'User') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const UserDashboard()), (r) => false);
      } else if (role == 'farmer' && loginType == 'Farmer') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const FarmerHomeScreen()), (r) => false);
      } else {
        await AuthService.logout();
        setState(() => isLoading = false);
        showMessage('Please select the correct login type for your account.');
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      showMessage('Something went wrong.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), color: primaryColor),
              const SizedBox(height: 10),
              Center(
                child: CircleAvatar(
                  radius: 55, backgroundColor: primaryColor,
                  child: Icon(loginType == 'Farmer' ? Icons.agriculture : Icons.person, color: Colors.white, size: 55),
                ),
              ),
              const SizedBox(height: 25),
              Center(child: Text('$loginType Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor))),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: loginTypeBtn('User', Icons.person, userColor)),
                  const SizedBox(width: 10),
                  Expanded(child: loginTypeBtn('Farmer', Icons.agriculture, farmerColor)),
                ],
              ),
              const SizedBox(height: 30),
              fieldLabel('Email'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecor('Enter your email', Icons.email_outlined),
              ),
              const SizedBox(height: 20),
              fieldLabel('Password'),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: inputDecor('Enter your password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: primaryColor),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(type: loginType)));
                  },
                  child: Text('Forgot Password?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Login as $loginType', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(registerType: loginType))), child: Text('Register', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginTypeBtn(String type, IconData icon, Color color) {
    bool selected = loginType == type;
    return GestureDetector(
      onTap: () => changeLoginType(type),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(type, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget fieldLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)));

  InputDecoration inputDecor(String h, IconData i) => InputDecoration(
    hintText: h, prefixIcon: Icon(i, color: primaryColor), filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 2)),
  );
}
