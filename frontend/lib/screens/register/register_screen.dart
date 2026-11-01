import 'package:flutter/material.dart';

import '../../core/constants/theme/auth_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_components.dart';
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

  late String currentType;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  bool get isFarmer => currentType.trim().toLowerCase() == 'farmer';
  RoleThemeConfig get config => RoleThemeConfig.fromKey(currentType);

  @override
  void initState() {
    super.initState();
    currentType = widget.registerType.trim().toLowerCase() == 'farmer'
        ? 'Farmer'
        : 'User';
  }

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

  Future<void> register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      AuthNotifier.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    try {
      AuthResult authResult;
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
        AuthNotifier.showSuccess(
          context,
          '${isFarmer ? 'Farmer' : 'Consumer'} account created successfully!',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(initialLoginType: currentType),
          ),
          (route) => false,
        );
      } else {
        AuthNotifier.showError(context, authResult.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AuthNotifier.showError(context, 'Unable to connect to the server.');
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Toggle Pill
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeToggle(
                              type: 'User',
                              label: 'Consumer Account',
                              icon: Icons.person_rounded,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildTypeToggle(
                              type: 'Farmer',
                              label: 'Farmer Account',
                              icon: Icons.agriculture_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title & Description
                    Text(
                      isFarmer
                          ? 'Join as Agricultural Grower'
                          : 'Create Consumer Account',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFarmer
                          ? 'Register your farm to list harvests, access AI crop protection, and receive direct payments.'
                          : 'Sign up to order farm-fresh produce directly from local sustainable farmers.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Main Form Card
                    AuthElevatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name
                          AuthTextField(
                            controller: nameController,
                            label: 'Full Name',
                            hint: 'Your full name',
                            prefixIcon: Icons.badge_outlined,
                            config: config,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                          ),

                          const SizedBox(height: 18),

                          // Email
                          AuthTextField(
                            controller: emailController,
                            label: 'Email Address',
                            hint: 'you@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            config: config,
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'Valid email is required'
                                    : null,
                          ),

                          const SizedBox(height: 18),

                          // Phone Number
                          AuthTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            hint: '+91 98765 43210',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            config: config,
                            validator: (v) =>
                                (v == null || v.trim().length < 10)
                                    ? 'Valid 10-digit phone required'
                                    : null,
                          ),

                          // Farmer-Specific Fields
                          if (isFarmer) ...[
                            const SizedBox(height: 18),
                            AuthTextField(
                              controller: farmNameController,
                              label: 'Farm / Estate Name',
                              hint: 'Greenfield Organic Orchards',
                              prefixIcon: Icons.terrain_rounded,
                              config: config,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Farm name is required'
                                      : null,
                            ),
                            const SizedBox(height: 18),
                            AuthTextField(
                              controller: farmLocationController,
                              label: 'Farm District / Location',
                              hint: 'District, State (e.g. Pune, Maharashtra)',
                              prefixIcon: Icons.location_on_outlined,
                              config: config,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Farm location is required'
                                      : null,
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Recovery Hint
                          AuthTextField(
                            controller: recoveryHintController,
                            label: 'Account Recovery Hint',
                            hint: 'e.g. Mother\'s maiden city, favorite crop',
                            prefixIcon: Icons.help_outline_rounded,
                            config: config,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Recovery hint required for security'
                                    : null,
                          ),

                          const SizedBox(height: 18),

                          // Password
                          AuthTextField(
                            controller: passwordController,
                            label: 'Password',
                            hint: 'Min. 6 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureText: hidePassword,
                            onToggleObscure: () {
                              setState(() => hidePassword = !hidePassword);
                            },
                            config: config,
                            validator: (v) =>
                                (v == null || v.length < 6)
                                    ? 'Minimum 6 characters'
                                    : null,
                          ),

                          const SizedBox(height: 18),

                          // Confirm Password
                          AuthTextField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            prefixIcon: Icons.lock_reset_rounded,
                            isPassword: true,
                            obscureText: hideConfirmPassword,
                            onToggleObscure: () {
                              setState(
                                () => hideConfirmPassword = !hideConfirmPassword,
                              );
                            },
                            config: config,
                            validator: (v) {
                              if (v != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          AuthGradientButton(
                            text: 'Create ${isFarmer ? 'Farmer' : 'Consumer'} Account',
                            onPressed: register,
                            isLoading: isLoading,
                            config: config,
                            icon: Icons.check_circle_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have an account
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already registered? ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(
                                    initialLoginType: currentType,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: config.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = currentType.toLowerCase() == type.toLowerCase();
    final roleConfig = RoleThemeConfig.fromKey(type);

    return GestureDetector(
      onTap: () {
        if (currentType != type && !isLoading) {
          setState(() {
            currentType = type;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? roleConfig.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
