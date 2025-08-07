import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../views/favourite_screen.dart';
import '../views/home_screen.dart';
import '../views/settings_screen.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  final ThemeController themeController = Get.find();
  final List<Widget> _screens = [
    HomeView(),
    FavoriteNotesView(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
          elevation: 8,
          selectedItemColor:
              isDark ? Colors.white : theme.primaryColor, // Vibrant pink
          unselectedItemColor: theme.colorScheme.onSurfaceVariant.withOpacity(
            0.6,
          ),
          selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.note_alt,
                size: 28,
                color:
                    _currentIndex == 0
                        ? isDark
                            ? Colors.white
                            : theme.primaryColor
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              activeIcon: Icon(
                Icons.note_alt,
                size: 28,
                color:
                    isDark ? Colors.white : theme.primaryColor, // Vibrant pink
              ),
              label: 'Notes',
              tooltip: 'View all notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                size: 28,
                color:
                    _currentIndex == 1
                        ? isDark
                            ? Colors.white
                            : theme
                                .primaryColor // Vibrant pink
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              activeIcon: Icon(
                Icons.favorite,
                size: 28,
                color:
                    isDark ? Colors.white : theme.primaryColor, // Vibrant pink
              ),
              label: 'Favorites',
              tooltip: 'View favorite notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                size: 28,
                color:
                    _currentIndex == 2
                        ? isDark
                            ? Colors.white
                            : theme
                                .primaryColor // Vibrant pink
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              activeIcon: Icon(
                Icons.settings,
                size: 28,
                color:
                    isDark ? Colors.white : theme.primaryColor, // Vibrant pink
              ),
              label: 'Settings',
              tooltip: 'App settings',
            ),
          ],
        ),
      ),
    );
  }
}
