import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/widgets/note_card.dart';

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
        extendBodyBehindAppBar: true,
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            // Top gradient backdrop
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [theme.colorScheme.surface, Colors.black12]
                          : [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Glass blur overlay
            Positioned.fill(
              top: -40,
              child: IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                // Glassy SliverAppBar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  expandedHeight: 140,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 16),
                    title: Text(
                      'Favorite Notes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    background: const SizedBox.shrink(),
                  ),
                ),

                // Pinned glass search bar (fixed: expands to header height)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _GlassSearchBarDelegate(
                    minExtent: 66,
                    maxExtent: 72,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(
                                isDark ? 0.25 : 0.65,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.12,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.search),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: 'Search favorites...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_searchCtrl.text.isNotEmpty)
                                  IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

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
          ],
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

/// Pinned header delegate for the glass search bar (fixed: expand to header height)
class _GlassSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget child;

  _GlassSearchBarDelegate({
    required double minExtent,
    required double maxExtent,
    required this.child,
  }) : _minExtent = minExtent,
       _maxExtent = maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Ensures paintExtent >= layoutExtent by filling current sliver height.
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _GlassSearchBarDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate._minExtent != _minExtent ||
        oldDelegate._maxExtent != _maxExtent;
  }
}
