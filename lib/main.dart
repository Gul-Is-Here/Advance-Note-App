import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/data/local/db_helper.dart';
import 'package:note_app/services/ad_service.dart';
import 'package:note_app/services/shorebird_service.dart';
import 'package:note_app/utility/themes.dart';
import 'package:note_app/views/favourite_screen.dart';
import 'package:note_app/views/home_screen.dart';
import 'package:note_app/views/settings_screen.dart';
import 'package:note_app/views/splash_screen.dart';
import 'package:note_app/widgets/banner_ad_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  Get.put<DatabaseHelper>(dbHelper, permanent: true);

  // Initialize AdService early
  Get.put<AdService>(AdService(), permanent: true);

  // Initialize Shorebird Service (the magic updater!)
  Get.put<ShorebirdService>(ShorebirdService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes App',
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      initialBinding: AppBindings(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteController());
    Get.lazyPut(() => ThemeController());
    // AdService is already initialized in main()
  }
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  int _navigationCount = 0;
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

    final Color selectedColor =
        isDark ? Colors.white : theme.colorScheme.primary;
    final Color unselectedColor =
        isDark
            ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6)
            : theme.colorScheme.secondary.withOpacity(0.6);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _navigationCount++;
              setState(() => _currentIndex = index);

              // Show interstitial ad after every 7 navigations
              if (_navigationCount % 7 == 0) {
                final adService = AdService.instance;
                if (adService.isInterstitialAdReady) {
                  adService.showInterstitialAd();
                }
              }
            },
            backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
            elevation: 8,
            selectedItemColor: selectedColor,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: selectedColor,
            ),
            unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: unselectedColor,
            ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.note_alt,
                  size: 28,
                  color: _currentIndex == 0 ? selectedColor : unselectedColor,
                ),
                activeIcon: Icon(
                  Icons.note_alt,
                  size: 28,
                  color: selectedColor,
                ),
                label: 'Notes',
                tooltip: 'View all notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  size: 28,
                  color: _currentIndex == 1 ? selectedColor : unselectedColor,
                ),
                activeIcon: Icon(
                  Icons.favorite,
                  size: 28,
                  color: selectedColor,
                ),
                label: 'Favorites',
                tooltip: 'View favorite notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 28,
                  color: _currentIndex == 2 ? selectedColor : unselectedColor,
                ),
                activeIcon: Icon(
                  Icons.settings,
                  size: 28,
                  color: selectedColor,
                ),
                label: 'Settings',
                tooltip: 'App settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
