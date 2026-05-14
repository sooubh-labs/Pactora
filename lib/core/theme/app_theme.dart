import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      backgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.secondary,
      surfaceColor: AppColors.surface,
      errorColor: AppColors.error,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textTertiary: AppColors.textTertiary,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      backgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.secondary, // Use secondary as primary in dark mode for better visibility
      secondaryColor: AppColors.secondary,
      surfaceColor: AppColors.surfaceDark,
      errorColor: AppColors.error,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      textTertiary: AppColors.textTertiaryDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color backgroundColor,
    required Color primaryColor,
    required Color secondaryColor,
    required Color surfaceColor,
    required Color errorColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
  }) {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      appBarTheme: _appBarTheme(primaryColor: primaryColor, textPrimary: textPrimary),
      cardTheme: _cardTheme(surfaceColor: surfaceColor),
      elevatedButtonTheme: _elevatedButtonTheme(primaryColor: primaryColor),
      floatingActionButtonTheme: _floatingActionButtonTheme(primaryColor: primaryColor),
      tabBarTheme: _tabBarTheme(primaryColor: primaryColor, textTertiary: textTertiary),
      textTheme: _textTheme(
        baseTextTheme: baseTextTheme,
        primaryColor: brightness == Brightness.light ? primaryColor : textPrimary,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textTertiary: textTertiary,
      ),
    );
  }

  static AppBarTheme _appBarTheme({required Color primaryColor, required Color textPrimary}) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary, size: 24),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  static CardThemeData _cardTheme({required Color surfaceColor}) {
    return CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({required Color primaryColor}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(64, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme({required Color primaryColor}) {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static TabBarThemeData _tabBarTheme({required Color primaryColor, required Color textTertiary}) {
    return TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textTertiary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 15),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  static TextTheme _textTheme({
    required TextTheme baseTextTheme,
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
  }) {
    return baseTextTheme.copyWith(
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: textSecondary,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Legacy methods to maintain compatibility
  static ThemeData buildLightTheme() => lightTheme;
  static ThemeData buildDarkTheme() => darkTheme;
}
