import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/widgets/note_card.dart';

class FavoriteNotesView extends StatelessWidget {
  FavoriteNotesView({super.key});
  final ThemeController themeController = Get.find();
  final NoteController noteController = Get.find<NoteController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              expandedHeight: 120,
              elevation: theme.appBarTheme.elevation,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 16),
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
            favoriteNotes.isEmpty
                ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.7,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No favorite notes yet!",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Mark some notes as favorite to see them here",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                : SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final note = favoriteNotes[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Dismissible(
                            key: Key(note.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed:
                                (direction) =>
                                    noteController.deleteNote(note.id!),
                            child: NoteCard(note: note),
                          ),
                        ),
                      );
                    }, childCount: favoriteNotes.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                  ),
                ),
          ],
        ),
      );
    });
  }
}
