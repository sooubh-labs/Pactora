import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color secondary = Color(0xFF6366F1);
  static const Color background = Color(0xFFF9FAFB); // Off-white
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Legacy Status colors (to be migrated)
  static const Color overdue = error;
  static const Color pending = secondary;
  static const Color complete = success;
  static const Color active = primary;

  // Legacy Category colors (to be migrated)
  static const Color money = Color(0xFF26C6DA);
  static const Color task = Color(0xFFAB47BC);
  static const Color meeting = Color(0xFFEC407A);
  static const Color borrow = Color(0xFFFF7043);
}
