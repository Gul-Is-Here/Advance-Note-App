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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            title: Text(
              "Settings",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
            elevation: theme.appBarTheme.elevation,
            backgroundColor: theme.appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [theme.colorScheme.surface, Colors.grey[850]!]
                            : [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Card(
                      shape: theme.cardTheme.shape,
                      elevation: theme.cardTheme.elevation,
                      color: theme.cardTheme.color,
                      child: SwitchListTile(
                        activeColor: theme.colorScheme.primary,
                        title: Text(
                          'Dark Mode',
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          'Toggle light/dark theme',
                          style: theme.textTheme.bodyMedium,
                        ),
                        secondary: Icon(
                          themeController.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                        ),
                        value: themeController.isDarkMode.value,
                        onChanged: (_) => themeController.toggleTheme(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Utilities",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: theme.cardTheme.shape,
                    elevation: theme.cardTheme.elevation,
                    color: theme.cardTheme.color,
                    child: ListTile(
                      leading: Icon(
                        Icons.import_export,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Export Notes',
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'Save notes as .json file',
                        style: theme.textTheme.bodyMedium,
                      ),
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
      Get.snackbar(
        "Error",
        "Failed to export notes: ${e.toString()}",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}
