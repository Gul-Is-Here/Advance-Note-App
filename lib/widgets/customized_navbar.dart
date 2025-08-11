import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _MainNavigationViewState extends State<MainNavigationView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ThemeController themeController = Get.find();

  final List<Widget> _screens = [
    HomeView(),
    FavoriteNotesView(),
    SettingsScreen(),
  ];

  int get _favCount => 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.12),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface.withOpacity(isDark ? 0.30 : 0.75),
                    theme.colorScheme.surface.withOpacity(isDark ? 0.20 : 0.55),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 64,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  indicatorColor: theme.colorScheme.primary,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    final color =
                        isDark
                            ? Colors.white
                            : Colors.black; // black for light theme
                    return theme.textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.2,
                      color: color,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    final color =
                        isDark
                            ? (selected
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant)
                            : (selected ? Colors.black : Colors.black54);
                    return IconThemeData(
                      size: selected ? 28 : 26,
                      color: color,
                    );
                  }),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentIndex = index);
                  },
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.note_alt_outlined),
                      selectedIcon: Icon(Icons.note_alt),
                      label: 'Notes',
                      tooltip: 'View all notes',
                    ),
                    NavigationDestination(
                      icon:
                          _favCount > 0
                              ? Badge(
                                label: Text('$_favCount'),
                                child: const Icon(Icons.favorite_border),
                              )
                              : const Icon(Icons.favorite_border),
                      selectedIcon:
                          _favCount > 0
                              ? Badge(
                                label: Text('$_favCount'),
                                child: const Icon(Icons.favorite),
                              )
                              : const Icon(Icons.favorite),
                      label: 'Favorites',
                      tooltip: 'View favorite notes',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                      tooltip: 'App settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
