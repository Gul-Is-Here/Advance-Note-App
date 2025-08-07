import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00FFA3),
      brightness: Brightness.light,
      primary: const Color(0xFF00FFA3), // Neon green
      secondary: Colors.black,
      surface: Colors.grey[100]!, // Lighter surface for modern look
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey[900]!,
      surfaceTint: const Color(0xFF00FFA3),
      error: Colors.redAccent,
      onSurfaceVariant: Colors.grey[700]!, // Added for better contrast
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00FFA3), // Neon green
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      extendedTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: const Color(0xFF00FFA3).withOpacity(0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: Colors.grey[900],
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.grey[900],
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: Colors.grey[900],
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: Colors.grey[700],
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: Colors.grey[600],
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF00FFA3), // Neon green
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
        fontSize: 12,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF00FFA3), // Neon green
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF00FFA3), // Neon green
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00FFA3),
      brightness: Brightness.dark,
      primary: const Color(0xFF00FFA3), // Neon green
      secondary: Colors.black,
      surface: Colors.grey[900]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey[200]!,
      surfaceTint: const Color(0xFF00FFA3),
      error: Colors.redAccent[200],
      onSurfaceVariant: Colors.grey[400]!, // Added for better contrast
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00FFA3), // Neon green
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      extendedTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[850],
      elevation: 4,
      shadowColor: const Color(0xFF00FFA3).withOpacity(0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: Colors.grey[200],
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.grey[200],
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: Colors.grey[200],
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: Colors.grey[400],
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: Colors.grey[500],
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF00FFA3), // Neon green
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: Colors.grey[400],
        fontSize: 12,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF00FFA3), // Neon green
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF00FFA3), // Neon green
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}
