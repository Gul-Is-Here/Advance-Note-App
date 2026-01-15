import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/utility/app_colors.dart';

class Themes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.getLightColorScheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: AppColors.lightOnSurface,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: AppColors.primaryGreen.withOpacity(0.2),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.lightOnPrimary,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      extendedTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: const Color(0xFF08C27B).withOpacity(0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.lightOnSurface,
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnSurface,
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnSurface,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: AppColors.lightOnSurfaceVariant,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: AppColors.lightOnSurfaceVariant,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnSurfaceVariant,
        fontSize: 12,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryGreen,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryGreen,
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
    colorScheme: AppColors.getDarkColorScheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: AppColors.darkOnSurface,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      extendedTextStyle: const TextStyle(
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
        color: AppColors.darkOnSurface,
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.darkOnSurface,
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.darkOnSurface,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 12,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryGreen,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryGreen,
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
