import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/data/local/db_helper.dart';
import 'package:note_app/utility/themes.dart';
import 'package:note_app/views/favourite_screen.dart';
import 'package:note_app/views/home_screen.dart';
import 'package:note_app/views/settings_screen.dart';
import 'package:note_app/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  Get.put<DatabaseHelper>(dbHelper, permanent: true);

  runApp(MyApp());
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
      home: SplashScreen(),
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
  }
}

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

  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    // final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavKey,
        index: _currentIndex,
        height: 60.0,
        backgroundColor: Colors.transparent,
        color: isDark ? Colors.black : Colors.pinkAccent,
        buttonBackgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(
            Icons.note,
            size: 30,
            color: _currentIndex == 0 ? Colors.pink : Colors.white,
          ),
          Icon(
            Icons.favorite,
            size: 30,
            color: _currentIndex == 1 ? Colors.pink : Colors.white,
          ),
          Icon(
            Icons.settings,
            size: 30,
            color: _currentIndex == 2 ? Colors.pink : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
