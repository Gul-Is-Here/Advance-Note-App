import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/services/shorebird_service.dart';
import 'package:note_app/widgets/update_widget.dart';
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
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
            elevation: theme.appBarTheme.elevation,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(bottom: 16),
              centerTitle: true,
              background: DecoratedBox(
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedCard(
                    child: Obx(
                      () => SwitchListTile(
                        activeColor: const Color(0xFFE91E63), // Vibrant pink
                        inactiveTrackColor: Colors.grey.withOpacity(0.5),
                        title: Text(
                          'Dark Mode',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Toggle between light and dark theme',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        secondary: Icon(
                          themeController.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: const Color(0xFF4A00E0), // Deep purple
                        ),
                        value: themeController.isDarkMode.value,
                        onChanged: (_) => themeController.toggleTheme(),
                      ),
                    ),
                    theme: theme,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Utilities",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Shorebird Update Widget
                  const UpdateWidget(),

                  _buildAnimatedCard(
                    child: ListTile(
                      leading: const Icon(
                        Icons.system_update,
                        color: Color(0xFF00C853), // Green color
                      ),
                      title: Text(
                        'Check for Updates',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Check for app updates instantly',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () {
                        ShorebirdService.instance.checkForUpdatesManually();
                        Get.snackbar(
                          'Checking...',
                          'Looking for updates...',
                          duration: const Duration(seconds: 2),
                        );
                      },
                    ),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),

                  _buildAnimatedCard(
                    child: ListTile(
                      leading: const Icon(
                        Icons.import_export,
                        color: Color(0xFF4A00E0), // Deep purple
                      ),
                      title: Text(
                        'Export Notes',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Save notes as a JSON file',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _exportNotes(context),
                    ),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, required ThemeData theme}) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        shape: theme.cardTheme.shape,
        elevation: theme.cardTheme.elevation,
        color: theme.cardTheme.color,
        shadowColor: theme.cardTheme.shadowColor,
        child: child,
      ),
    );
  }

  Future<void> _exportNotes(BuildContext context) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              Color(0xFFE91E63),
            ), // Vibrant pink
          ),
        ),
        barrierDismissible: false,
      );

      final notes = noteController.notes.map((n) => n.toMap()).toList();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(notes);

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/notes_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);

      // Close loading dialog
      Get.back();

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My exported notes from NoteApp!');

      Get.snackbar(
        'Success',
        'Notes exported successfully!',
        backgroundColor: const Color(0xFF4A00E0), // Deep purple
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Error',
        'Failed to export notes: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _confirmClearNotes(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Clear All Notes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all notes? This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete All'),
              ),
            ],
          ),
    );

    // if (confirmed == true) {
    //   try {
    //     await noteController.clearAllNotes();
    //     Get.snackbar(
    //       'Success',
    //       'All notes deleted successfully!',
    //       backgroundColor: const Color(0xFF4A00E0), // Deep purple
    //       colorText: Colors.white,
    //       snackPosition: SnackPosition.BOTTOM,
    //       margin: const EdgeInsets.all(16),
    //       borderRadius: 12,
    //     );
    //   } catch (e) {
    //     Get.snackbar(
    //       'Error',
    //       'Failed to delete notes: ${e.toString()}',
    //       backgroundColor: Colors.redAccent,
    //       colorText: Colors.white,
    //       snackPosition: SnackPosition.BOTTOM,
    //       margin: const EdgeInsets.all(16),
    //       borderRadius: 12,
    //     );
    //   }
    // }z
  }
}
