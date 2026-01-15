import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Run this script to generate a modern app icon
/// Usage: dart run generate_icon.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🎨 Generating modern Notes app icon...');

  // Create the icon widget
  final iconWidget = Container(
    width: 1024,
    height: 1024,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF08C27B), // Primary green
          Color(0xFF06A368), // Darker green
        ],
      ),
    ),
    child: Center(
      child: Container(
        width: 700,
        height: 800,
        child: CustomPaint(painter: NoteIconPainter()),
      ),
    ),
  );

  print('✅ Icon design created!');
  print('');
  print('📋 To generate the actual icon, please follow these steps:');
  print('');
  print('1. Use an online tool like:');
  print('   - https://www.canva.com (Free)');
  print('   - https://www.figma.com (Free)');
  print('   - https://icon.kitchen (Quick & Free)');
  print('');
  print('2. Create a 1024x1024px canvas with these specifications:');
  print('   Background: Linear gradient');
  print('   - Top-left: #08C27B (Your app\'s primary green)');
  print('   - Bottom-right: #06A368 (Darker shade)');
  print('');
  print('3. Add a white notepad icon in the center:');
  print('   - Use Material Icons "description" or "note" symbol');
  print('   - Size: 600-700px');
  print('   - Color: White (#FFFFFF)');
  print('   - Add a subtle shadow for depth');
  print('   - Optional: Add small pen icon in corner');
  print('');
  print('4. Save as "noteicon.png" (1024x1024px)');
  print('');
  print('5. Replace the file at: assets/images/noteicon.png');
  print('');
  print('6. Run: flutter pub run flutter_launcher_icons');
  print('');
  print('🎨 Alternative: Use the icon.kitchen quick method below!');
}

class NoteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

    // Draw notepad body
    final noteRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(100, 50, size.width - 200, size.height - 100),
      Radius.circular(40),
    );

    // Shadow
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRRect(noteRect.shift(Offset(10, 10)), shadowPaint);

    // Main body
    canvas.drawRRect(noteRect, paint);

    // Lines on notepad
    final linePaint =
        Paint()
          ..color = Color(0xFF08C27B).withOpacity(0.2)
          ..strokeWidth = 4;

    for (int i = 0; i < 6; i++) {
      final y = 200.0 + (i * 100.0);
      canvas.drawLine(Offset(200, y), Offset(size.width - 200, y), linePaint);
    }

    // Top binding holes
    for (int i = 0; i < 3; i++) {
      final x = size.width / 2 - 100 + (i * 100.0);
      canvas.drawCircle(Offset(x, 100), 15, Paint()..color = Color(0xFF08C27B));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
