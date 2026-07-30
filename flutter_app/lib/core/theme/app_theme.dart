import 'package:flutter/material.dart';

class AppTheme {
  // Shared design tokens
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color secondaryMint = Color(0xFFD1FAE5);
  static const Color backgroundLight = Color(0xFFF8FAF8);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: secondaryMint,
        surface: cardWhite,
      ),
      scaffoldBackgroundColor: backgroundLight,
      
      // Large, legible typography scale for elderly-friendly UX
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 18, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 16, color: textSecondary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      
      // 20–24px rounded card shape
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      // Minimum 48x48 tap target for elderly accessibility
      materialTapTargetSize: MaterialTapTargetSize.padded,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryEmerald,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
