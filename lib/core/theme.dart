import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  
  // Dark Theme Colors
  static const Color backgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color surfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurfaceColor = Color(0xFFFFFFFF); // White
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600

  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500

  static ThemeData darkTheme = _buildTheme(Brightness.dark);
  static ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color bgColor = isDark ? backgroundColor : lightBackgroundColor;
    final Color surfColor = isDark ? surfaceColor : lightSurfaceColor;
    final Color txtPrimary = isDark ? textPrimary : lightTextPrimary;
    final Color txtSecondary = isDark ? textSecondary : lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfColor,
        onSurface: txtPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: txtPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: txtPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: txtPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: txtPrimary),
          bodyMedium: TextStyle(color: txtSecondary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: txtPrimary),
        titleTextStyle: TextStyle(
          color: txtPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceColor : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: txtSecondary),
        hintStyle: TextStyle(color: txtSecondary.withOpacity(0.5)),
        prefixIconColor: txtSecondary,
      ),
      cardTheme: CardThemeData(
        color: surfColor,
        elevation: isDark ? 0 : 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
