import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/widgets/note_card.dart';
import 'package:note_app/widgets/custom_app_bar.dart';

class FavoriteNotesView extends StatefulWidget {
  const FavoriteNotesView({super.key});

  @override
  State<FavoriteNotesView> createState() => _FavoriteNotesViewState();
}

class _FavoriteNotesViewState extends State<FavoriteNotesView> {
  final ThemeController themeController = Get.find();
  final NoteController noteController = Get.find<NoteController>();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _columnsForWidth(double w) {
    if (w >= 1400) return 5;
    if (w >= 1100) return 4;
    if (w >= 800) return 3;
    return 2;
  }

  double _aspectForWidth(double w) {
    if (w >= 1100) return 0.78;
    if (w >= 800) return 0.72;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final favs =
          noteController.notes.where((n) => n.isFavorite).where((n) {
            final q = _searchCtrl.text.trim().toLowerCase();
            if (q.isEmpty) return true;
            return n.title.toLowerCase().contains(q) ||
                n.category.toLowerCase().contains(q);
          }).toList();

      final size = MediaQuery.of(context).size;
      final cols = _columnsForWidth(size.width);
      final aspect = _aspectForWidth(size.width);

      return Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom AppBar
              SliverToBoxAdapter(
                child: CustomAppBar(
                  title: 'Favorite Notes',
                  subtitle:
                      '${favs.length} favorite ${favs.length == 1 ? 'note' : 'notes'}',
                  showThemeToggle: true,
                  showBackButton: false,
                ),
              ),

              // Search bar - simple style matching home
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search favorites...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 24,
                      ),
                      suffixIcon:
                          _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              if (favs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 88,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorite notes yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the heart on any note to pin it here.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final note = favs[index];
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.94, end: 1.0),
                        builder:
                            (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Dismissible(
                            key: Key('fav_${note.id}'),
                            direction: DismissDirection.endToStart,
                            background: const _DeleteBackground(),
                            onDismissed:
                                (_) => noteController.deleteNote(note.id!),
                            child: NoteCard(note: note),
                          ),
                        ),
                      );
                    }, childCount: favs.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: aspect,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 26),
    );
  }
}
