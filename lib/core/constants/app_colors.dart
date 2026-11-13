import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1E3A8A); // Deep Slate Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);
  static const Color accent = Color(0xFF0EA5E9); // Sky

  // Secondary Palette
  static const Color secondary = Color(0xFF0F766E); // Deep Teal
  static const Color secondaryLight = Color(0xFF14B8A6);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

