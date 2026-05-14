import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF28286A); // Deep Indigo
  static const Color primaryLight = Color(0xFF4A4A9A);
  static const Color accent = Color(0xFF6B6BF5);
  static const Color secondary = Color(0xFF818CF8);

  // Background & Surface
  static const Color background = Color(0xFFF8F8FD);
  static const Color surface = Colors.white;
  static const Color cardShadow = Color(0x0A000000);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A3A);
  static const Color textSecondary = Color(0xFF5A5A7A);
  static const Color textTertiary = Color(0xFF9A9AB0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color border = Color(0xFFE8E8F0);

  // Specific Status Chip Colors (from design)
  static const Color overdueBg = Color(0xFFFFF0F0);
  static const Color overdueText = Color(0xFFE53935);
  
  static const Color pendingBg = Color(0xFFEAF0FF);
  static const Color pendingText = Color(0xFF3960D1);
  
  static const Color doneBg = Color(0xFFEBE8F0);
  static const Color doneText = Color(0xFF6B6082);

  // Semantic mappings
  static const Color overdue = error;
  static const Color pending = info;
  static const Color complete = success;
  static const Color active = primary;

  // Category Colors
  static const Color money = Color(0xFF0EA5E9);
  static const Color task = Color(0xFF8B5CF6);
  static const Color meeting = Color(0xFFEC4899);
  static const Color borrow = Color(0xFFF97316);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
}
