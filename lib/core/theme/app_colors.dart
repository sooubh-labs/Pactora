import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E1B4B); // Deep Navy/Indigo
  static const Color primaryLight = Color(0xFF4338CA);
  static const Color accent = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF818CF8);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardShadow = Color(0x0A000000);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color border = Color(0xFFE2E8F0);

  // Semantic mappings
  static const Color overdue = error;
  static const Color pending = warning;
  static const Color complete = success;
  static const Color active = accent;

  // Category Colors
  static const Color money = Color(0xFF0EA5E9);
  static const Color task = Color(0xFF8B5CF6);
  static const Color meeting = Color(0xFFEC4899);
  static const Color borrow = Color(0xFFF97316);
}
