import 'package:flutter/material.dart';

class AppColors {
  // Modern Forest Pine & Sage Palette (Refined Light Aesthetic)
  static const Color primary = Color(0xFF1E6050); // Deep Forest Pine
  static const Color primaryDark = Color(0xFF134539);
  static const Color primaryLight = Color(0xFF287D69);
  
  // Soft Sage & Mint Tints
  static const Color sageLight = Color(0xFFEBF5F1); // Soft sage background tint
  static const Color sageMedium = Color(0xFFD3EBE1);
  static const Color sageBorder = Color(0xFFDAE9E3);
  static const Color mintAccent = Color(0xFF38B28B);

  // Warm Muted Gold Accents
  static const Color goldAccent = Color(0xFFC89D42);
  static const Color goldLight = Color(0xFFFDF6E2);
  static const Color goldBorder = Color(0xFFEEDBB2);

  // Backgrounds & Clean Surfaces
  static const Color background = Color(0xFFF6FAF8); // Crisp soft alabaster
  static const Color surface = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceVariant = Color(0xFFF0F6F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF102821); // Deep pine charcoal
  static const Color textSecondary = Color(0xFF55776C); // Sage slate
  static const Color textMuted = Color(0xFF8BA59C);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Prayer Colors
  static const Color activeGreen = Color(0xFF2E9E78);
  static const Color error = Color(0xFFD9534F);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E6050), Color(0xFF14473B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sageCardGradient = LinearGradient(
    colors: [Color(0xFFF4FAF7), Color(0xFFEAF5F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF1E6050), Color(0xFF164D40), Color(0xFF0F382E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    colors: [Color(0xFFDFB65E), Color(0xFFC89D42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
