import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Shared design tokens
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color secondaryMint = Color(0xFFD1FAE5);
  static const Color backgroundLight = Color(0xFFF7FAF7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Dark Mode tokens — Deep Charcoal Grayish (not bluish gray)
  static const Color backgroundDark = Color(0xFF121214);
  static const Color cardDark = Color(0xFF1E1E22);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color darkSecondaryMint = Color(0xFF064E3B);

  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);

  static const String fontFamilyName = 'PlusJakartaSans';

  static TextTheme get _plusJakartaSansTextTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);
    return base.apply(fontFamily: fontFamilyName).copyWith(
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary),
      titleLarge: base.titleLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
      titleMedium: base.titleMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 18, color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 16, color: textSecondary),
      labelLarge: base.labelLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  static TextTheme get _darkPlusJakartaSansTextTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    return base.apply(fontFamily: fontFamilyName).copyWith(
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 26, fontWeight: FontWeight.bold, color: textPrimaryDark),
      titleLarge: base.titleLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryDark),
      titleMedium: base.titleMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryDark),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 18, color: textPrimaryDark),
      bodyMedium: base.bodyMedium?.copyWith(fontFamily: fontFamilyName, fontSize: 16, color: textSecondaryDark),
      labelLarge: base.labelLarge?.copyWith(fontFamily: fontFamilyName, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamilyName,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        brightness: Brightness.light,
        primary: primaryEmerald,
        secondary: secondaryMint,
        surface: cardWhite,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _plusJakartaSansTextTheme,
      primaryTextTheme: _plusJakartaSansTextTheme,
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF3F4F6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF9CA3AF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryEmerald;
          return const Color(0xFFE5E7EB);
        }),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontFamily: fontFamilyName, fontSize: 18, fontWeight: FontWeight.bold),
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamilyName,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        brightness: Brightness.dark,
        primary: primaryEmerald,
        secondary: darkSecondaryMint,
        surface: cardDark,
        onSurface: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _darkPlusJakartaSansTextTheme,
      primaryTextTheme: _darkPlusJakartaSansTextTheme,
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D32),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF71717A);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryEmerald;
          return const Color(0xFF27272A);
        }),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryEmerald,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
