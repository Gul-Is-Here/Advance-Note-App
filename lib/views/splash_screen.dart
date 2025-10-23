import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/main.dart';
import 'package:lottie/lottie.dart';
import 'package:note_app/utility/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Navigate to main screen after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      Get.off(() => MainNavigationView());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Responsive icon with scale effect
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.note_alt,
                    size:
                        responsive.isMobile
                            ? responsive.wp(25)
                            : responsive.wp(15),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: responsive.hp(3)),
                // App title with responsive typography
                Text(
                  'MyNotes - Offline',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: responsive.sp(AppTextSize.heading1 + 8),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.hp(1.5)),
                // Subtitle with responsive text
                Padding(
                  padding: responsive.padding(horizontal: 32),
                  child: Text(
                    'Organize your thoughts beautifully',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: responsive.sp(AppTextSize.body),
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: responsive.hp(4)),
                // Loading indicator with responsive size
                SizedBox(
                  width: responsive.isMobile ? 40 : 50,
                  height: responsive.isMobile ? 40 : 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
