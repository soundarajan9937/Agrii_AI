import 'package:flutter/material.dart';

enum AuthRole {
  user,
  farmer,
  admin,
}

class RoleThemeConfig {
  final String roleKey;
  final String title;
  final String badge;
  final String subtitle;
  final String buttonText;
  final String registerPrompt;
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final List<Color> gradientColors;
  final Color primaryColor;
  final Color accentColor;
  final Color lightTint;
  final Color cardBorderColor;
  final Color glowColor;

  const RoleThemeConfig({
    required this.roleKey,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.buttonText,
    required this.registerPrompt,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.gradientColors,
    required this.primaryColor,
    required this.accentColor,
    required this.lightTint,
    required this.cardBorderColor,
    required this.glowColor,
  });

  static const RoleThemeConfig user = RoleThemeConfig(
    roleKey: 'User',
    title: 'Customer Care',
    badge: 'Eco Consumer',
    subtitle: 'Sign in to order fresh harvests & track orders',
    buttonText: 'Login as Consumer',
    registerPrompt: 'New to Agrii AI? Create an account',
    primaryIcon: Icons.shopping_basket_rounded,
    secondaryIcon: Icons.eco_rounded,
    gradientColors: [
      Color(0xFF0F766E), // Deep Teal
      Color(0xFF059669), // Emerald
      Color(0xFF0284C7), // Sky Azure
    ],
    primaryColor: Color(0xFF059669),
    accentColor: Color(0xFF10B981),
    lightTint: Color(0xFFECFDF5),
    cardBorderColor: Color(0xFFA7F3D0),
    glowColor: Color(0x3310B981),
  );

  static const RoleThemeConfig farmer = RoleThemeConfig(
    roleKey: 'Farmer',
    title: 'Farmer & Grower',
    badge: 'Agri Producer',
    subtitle: 'Sign in to manage crops, AI scanner & earnings',
    buttonText: 'Login as Farmer',
    registerPrompt: 'Are you a grower? Register your farm',
    primaryIcon: Icons.agriculture_rounded,
    secondaryIcon: Icons.psychology_rounded,
    gradientColors: [
      Color(0xFFB45309), // Warm Ochre
      Color(0xFFD97706), // Golden Harvest
      Color(0xFFEA580C), // Sunrise Orange
    ],
    primaryColor: Color(0xFFD97706),
    accentColor: Color(0xFFF59E0B),
    lightTint: Color(0xFFFFFBEB),
    cardBorderColor: Color(0xFFFDE68A),
    glowColor: Color(0x33F59E0B),
  );

  static const RoleThemeConfig admin = RoleThemeConfig(
    roleKey: 'Admin',
    title: 'Admin Console',
    badge: 'Operations Root',
    subtitle: 'Authorized access for verification & platform analytics',
    buttonText: 'Enter Admin Console',
    registerPrompt: 'Administrative credentials are issued by SuperAdmin',
    primaryIcon: Icons.admin_panel_settings_rounded,
    secondaryIcon: Icons.security_rounded,
    gradientColors: [
      Color(0xFF000000), // Pure Black
      Color(0xFF08120B), // Deep Obsidian Dark
      Color(0xFF0F2615), // Cyber Dark Lime Glow
    ],
    primaryColor: Color(0xFF00FF00), // Electric Lime #00FF00
    accentColor: Color(0xFF00FF00),  // Electric Lime #00FF00
    lightTint: Color(0xFF0D140F),    // Dark Glass Surface
    cardBorderColor: Color(0xFF00FF00), // Lime Border
    glowColor: Color(0x4000FF00),    // 25% Lime Glow
  );

  static RoleThemeConfig fromKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'farmer':
        return farmer;
      case 'admin':
        return admin;
      case 'user':
      default:
        return user;
    }
  }
}

// ==========================================================
// ADMIN CYBER OBSIDIAN & ELECTRIC LIME (#00FF00) DESIGN SYSTEM
// ==========================================================

class AdminTheme {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF080B09);       // Deep pure obsidian
  static const Color surface = Color(0xFF101612);          // Dark card surface
  static const Color surfaceElevated = Color(0xFF151F19);  // Hover/active surface
  static const Color surfaceMuted = Color(0xFF0B100C);

  // Exact Lime Accent (#00FF00) from user specification
  static const Color lime = Color(0xFF00FF00);             // #00FF00 Electric Lime
  static const Color limeDark = Color(0xFF00CC00);
  static const Color limeGlow = Color(0x3300FF00);         // 20% glow
  static const Color limeTint = Color(0x1F00FF00);         // 12% tint
  static const Color limeBorder = Color(0x4D00FF00);       // 30% border

  // Structural Borders
  static const Color border = Color(0xFF19251D);
  static const Color borderLight = Color(0xFF263A2E);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);      // Pure crisp white
  static const Color textSecondary = Color(0xFFA1A1AA);    // Cool tech grey
  static const Color textMuted = Color(0xFF71717A);        // Muted slate
  static const Color textLime = Color(0xFF00FF00);         // Lime highlighted text

  // Status Colors
  static const Color danger = Color(0xFFEF4444);           // Rejection / Alert
  static const Color warning = Color(0xFFF59E0B);          // Pending / Caution
  static const Color blue = Color(0xFF38BDF8);             // Telemetry / Info

  // Header Gradient
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [
      Color(0xFF000000), // Pure Black
      Color(0xFF07100B), // Cyber Obsidian
      Color(0xFF0C2013), // Lime Tint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF111713),
      Color(0xFF0D120F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Standard Card Decoration
  static BoxDecoration cardDecoration({
    Color? borderColor,
    bool hasGlow = false,
    bool glow = false,
  }) {
    final bool enableGlow = hasGlow || glow;
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? border,
        width: 1,
      ),
      boxShadow: enableGlow
          ? [
              const BoxShadow(
                color: limeGlow,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // Rounded Lime Chip matching user image: Lime (#00FF00) background, black text
  static Widget limeChip(
    String text, {
    IconData? icon,
    bool isSolid = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? lime : limeTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSolid ? lime : limeBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: isSolid ? Colors.black : lime),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isSolid ? Colors.black : lime,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
