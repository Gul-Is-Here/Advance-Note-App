import 'package:flutter/material.dart';

/// Centralized color configuration for the entire app
/// Change colors here and they will update throughout the app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========== PRIMARY COLORS ==========
  /// Main brand color - used for primary actions, headers, FAB
  static const Color primaryGreen = Color(0xFF08C27B);

  /// Dark variant of primary color
  static const Color primaryDarkGreen = Color(0xFF000B07);

  /// Light tint of primary color for backgrounds
  static const Color primaryLight = Color(0xFF4FFFB0);

  /// Container backgrounds using primary color
  static const Color primaryContainer = Color(0xFF00E676);

  // ========== SECONDARY COLORS ==========
  /// Secondary accent color
  static const Color secondary = Color(0xFF03DAC6);

  /// Secondary container backgrounds
  static const Color secondaryContainer = Color(0xFF018786);

  // ========== TERTIARY COLORS ==========
  /// Tertiary color (used for special elements like lock icons)
  static const Color tertiary = Color(0xFFFFC107);

  /// Tertiary container
  static const Color tertiaryContainer = Color(0xFFFFD54F);

  // ========== STATUS COLORS ==========
  /// Error/destructive actions color
  static const Color error = Color(0xFFE53935);

  /// Error container
  static const Color errorContainer = Color(0xFFFFCDD2);

  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// Info color
  static const Color info = Color(0xFF2196F3);

  // ========== NEUTRAL COLORS - LIGHT THEME ==========
  /// Light theme surface color
  static const Color lightSurface = Color(0xFFFAFAFA);

  /// Light theme background
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Light theme card surface
  static const Color lightSurfaceContainer = Color(0xFFF5F5F5);

  /// Light theme elevated surface
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E0E0);

  // ========== NEUTRAL COLORS - DARK THEME ==========
  /// Dark theme surface color
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Dark theme background
  static const Color darkBackground = Color(0xFF121212);

  /// Dark theme card surface
  static const Color darkSurfaceContainer = Color(0xFF2C2C2C);

  /// Dark theme elevated surface
  static const Color darkSurfaceContainerHighest = Color(0xFF3A3A3A);

  // ========== TEXT COLORS - LIGHT THEME ==========
  static const Color lightOnSurface = Color(0xFF212121);
  static const Color lightOnSurfaceVariant = Color(0xFF757575);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // ========== TEXT COLORS - DARK THEME ==========
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnError = Color(0xFF000000);

  // ========== BORDER & OUTLINE ==========
  static const Color lightOutline = Color(0xFFBDBDBD);
  static const Color darkOutline = Color(0xFF616161);

  // ========== SHADOW ==========
  static const Color lightShadow = Color(0xFF000000);
  static const Color darkShadow = Color(0xFF000000);

  // ========== GRADIENT COLORS ==========
  /// Gradient start color for headers/cards
  static const Color gradientStart = primaryGreen;

  /// Gradient end color for headers/cards
  static const Color gradientEnd = Color(0xFF00BFA5);

  // ========== SPECIAL UI COLORS ==========
  /// Color for pinned items
  static const Color pinnedIndicator = primaryGreen;

  /// Color for locked items
  static const Color lockedIndicator = tertiary;

  /// Color for reminder notifications
  static const Color reminderIndicator = info;

  /// Color for favorite/like
  static const Color favoriteIndicator = error;

  // ========== TAG COLORS ==========
  /// Predefined colors for tags (can be extended)
  static const List<Color> tagColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];

  // ========== CATEGORY COLORS ==========
  static const Color workCategory = Color(0xFF2196F3);
  static const Color personalCategory = Color(0xFF9C27B0);
  static const Color ideasCategory = Color(0xFFFFC107);
  static const Color todoCategory = Color(0xFF4CAF50);
  static const Color generalCategory = Color(0xFF757575);

  // ========== HELPER METHODS ==========

  /// Get color for a specific category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return workCategory;
      case 'personal':
        return personalCategory;
      case 'ideas':
        return ideasCategory;
      case 'to-do':
      case 'todo':
        return todoCategory;
      case 'general':
      default:
        return generalCategory;
    }
  }

  /// Get a tag color by index (cycles through available colors)
  static Color getTagColor(int index) {
    return tagColors[index % tagColors.length];
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Create a color scheme for light theme
  static ColorScheme getLightColorScheme() {
    return ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primaryContainer,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      error: error,
      errorContainer: errorContainer,
      surface: lightSurface,
      surfaceContainerHighest: lightSurfaceContainerHighest,
      onPrimary: lightOnPrimary,
      onSecondary: lightOnSecondary,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      onError: lightOnError,
      outline: lightOutline,
      shadow: lightShadow,
    );
  }

  /// Create a color scheme for dark theme
  static ColorScheme getDarkColorScheme() {
    return ColorScheme.dark(
      primary: primaryGreen,
      primaryContainer: primaryDarkGreen,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      error: error,
      errorContainer: errorContainer,
      surface: darkSurface,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onPrimary: darkOnPrimary,
      onSecondary: darkOnSecondary,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      onError: darkOnError,
      outline: darkOutline,
      shadow: darkShadow,
    );
  }
}
