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
    final isDark = Get.isDarkMode;
    final NoteController noteController = Get.find<NoteController>();

    return Obx(() {
      final favoriteNotes =
          noteController.notes.where((note) => note.isFavorite).toList();

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text("Favorite Notes"),
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 120,
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
            favoriteNotes.isEmpty
                ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No favorite notes found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
