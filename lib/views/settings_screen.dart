import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();
  final NoteController noteController = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            title: const Text("Settings"),
            floating: true,
            snap: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [Colors.grey.shade900, Colors.black]
                            : [Colors.pink, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Preferences",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: SwitchListTile(
                        activeColor: isDark ? Colors.white : Colors.pink,
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Toggle light/dark theme'),
                        secondary: Icon(
                          themeController.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: isDark ? Colors.white : Colors.pink,
                        ),
                        value: themeController.isDarkMode.value,
                        onChanged: (_) => themeController.toggleTheme(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Utilities",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        Icons.import_export,
                        color: isDark ? Colors.white : Colors.pink,
                      ),
                      title: const Text('Export Notes'),
                      subtitle: const Text('Save notes as .json file'),
                      onTap: _exportNotes,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportNotes() async {
    try {
      final notes = noteController.notes.map((n) => n.toMap()).toList();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(notes);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/notes_export.json');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Here are my exported notes from NoteApp!');
    } catch (e) {
      Get.snackbar("Error", "Failed to export notes: ${e.toString()}");
    }
  }
}
