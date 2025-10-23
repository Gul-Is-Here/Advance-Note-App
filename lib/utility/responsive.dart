import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  // Get screen width
  double get width => MediaQuery.of(context).size.width;

  // Get screen height
  double get height => MediaQuery.of(context).size.height;

  // Check if device is mobile (width < 600)
  bool get isMobile => width < 600;

  // Check if device is tablet (600 <= width < 900)
  bool get isTablet => width >= 600 && width < 900;

  // Check if device is desktop (width >= 900)
  bool get isDesktop => width >= 900;

  // Responsive font size based on screen width
  double sp(double size) {
    // Base width for scaling (360dp is a common mobile width)
    const double baseWidth = 360.0;
    return (size * width) / baseWidth;
  }

  // Responsive width
  double wp(double percentage) {
    return (percentage / 100) * width;
  }

  // Responsive height
  double hp(double percentage) {
    return (percentage / 100) * height;
  }

  // Responsive padding
  EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? horizontal ?? all ?? 0,
      top: top ?? vertical ?? all ?? 0,
      right: right ?? horizontal ?? all ?? 0,
      bottom: bottom ?? vertical ?? all ?? 0,
    ).copyWith(
      left: (left ?? horizontal ?? all ?? 0) * (width / 360),
      top: (top ?? vertical ?? all ?? 0) * (width / 360),
      right: (right ?? horizontal ?? all ?? 0) * (width / 360),
      bottom: (bottom ?? vertical ?? all ?? 0) * (width / 360),
    );
  }

  // Get responsive text style
  TextStyle responsiveTextStyle(TextStyle style) {
    return style.copyWith(
      fontSize: style.fontSize != null ? sp(style.fontSize!) : null,
    );
  }

  // Responsive border radius
  BorderRadius borderRadius(double radius) {
    return BorderRadius.circular(radius * (width / 360));
  }

  // Responsive icon size
  double iconSize(double size) {
    return size * (width / 360);
  }

  // Get safe area padding
  EdgeInsets get safeArea => MediaQuery.of(context).padding;

  // Get keyboard height
  double get keyboardHeight => MediaQuery.of(context).viewInsets.bottom;

  // Check if keyboard is visible
  bool get isKeyboardVisible => keyboardHeight > 0;
}

// Extension method for easier access
extension ResponsiveContext on BuildContext {
  Responsive get responsive => Responsive(this);
}

// Text size constants for consistency
class AppTextSize {
  static const double heading1 = 32.0;
  static const double heading2 = 24.0;
  static const double heading3 = 20.0;
  static const double heading4 = 18.0;
  static const double body = 16.0;
  static const double bodySmall = 14.0;
  static const double caption = 12.0;
  static const double tiny = 10.0;
}
