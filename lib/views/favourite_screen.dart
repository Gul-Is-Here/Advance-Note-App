import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/widgets/note_card.dart';

class FavoriteNotesView extends StatelessWidget {
  FavoriteNotesView({super.key});
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final NoteController noteController = Get.find<NoteController>();

    return Obx(() {
      final favoriteNotes =
          noteController.notes.where((note) => note.isFavorite).toList();

      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                "Favorite Notes",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.appBarTheme.foregroundColor,
                ),
              ),
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 120,
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
            favoriteNotes.isEmpty
                ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No favorite notes found",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
                : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: NoteCard(note: favoriteNotes[index]),
                    );
                  }, childCount: favoriteNotes.length),
                ),
          ],
        ),
      );
    });
  }
}
