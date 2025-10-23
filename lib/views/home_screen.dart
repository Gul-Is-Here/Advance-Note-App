import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/ad_service.dart';
import 'package:note_app/utility/constants.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/banner_ad_widget.dart';
import 'package:note_app/widgets/note_card.dart';

class HomeView extends GetView<NoteController> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _showSearchBar = false.obs;

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          elevation: 4,
          shape: theme.floatingActionButtonTheme.shape,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () => Get.to(() => CreateNoteView()),
        ),
      ),
      body: Obx(
        () => CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: false,
              elevation: theme.appBarTheme.elevation,
              backgroundColor: theme.appBarTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Obx(
                  () => Text(
                    controller.selectedCategory.value == 'All'
                        ? 'All Notes'
                        : '${controller.selectedCategory.value} Notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: theme.appBarTheme.foregroundColor,
                    ),
                  ),
                ),
                centerTitle: true,
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
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: theme.appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchQuery.value = '';
                    _showSearchBar.toggle();
                  },
                ),
                _buildCategoryFilter(theme),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      Get.find<ThemeController>().isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: theme.appBarTheme.foregroundColor,
                    ),
                    onPressed: () => Get.find<ThemeController>().toggleTheme(),
                  ),
                ),
              ],
            ),
            if (_showSearchBar.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? theme.colorScheme.surfaceContainerHigh
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      style: theme.textTheme.bodyLarge,
                      onChanged: (value) {
                        controller.searchQuery.value = value;
                        controller.searchNotes(value);
                      },
                    ),
                  ),
                ),
              ),
            Obx(() {
              if (controller.isLoading.value) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }

              final notesToDisplay =
                  _showSearchBar.value && _searchController.text.isNotEmpty
                      ? controller.searchedNotes
                      : controller.filteredNotes;

              if (notesToDisplay.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showSearchBar.value &&
                                  _searchController.text.isNotEmpty
                              ? 'No results found'
                              : 'No notes yet!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showSearchBar.value &&
                                  _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Tap the + button to create your first note',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Calculate the actual note index considering ads
                      final adInterval = 3; // Show ad after every 3 notes
                      final isAdPosition = (index + 1) % (adInterval + 1) == 0;

                      if (isAdPosition && index != 0) {
                        // Show banner ad
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: BannerAdWidget(),
                        );
                      }

                      // Calculate actual note index
                      final noteIndex = index - (index ~/ (adInterval + 1));

                      if (noteIndex >= notesToDisplay.length) {
                        return const SizedBox.shrink();
                      }

                      final note = notesToDisplay[noteIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Dismissible(
                          key: Key(note.id.toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _showDeleteConfirmation(context, note);
                          },
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade300,
                                  Colors.red.shade500,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed:
                              (direction) => controller.deleteNote(note.id!),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 100),
                            child: NoteCard(note: note),
                          ),
                        ),
                      );
                    },
                    childCount:
                        notesToDisplay.length + (notesToDisplay.length ~/ 3),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return PopupMenuButton(
      icon: Icon(Icons.filter_list, color: theme.appBarTheme.foregroundColor),
      itemBuilder:
          (context) =>
              AppConstants.categories.map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Text(category, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  onTap: () => controller.selectedCategory.value = category,
                );
              }).toList(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Ideas':
        return Icons.lightbulb;
      case 'To-Do':
        return Icons.check_circle;
      default:
        return Icons.category;
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Note note) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.3),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delete Note',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete this note?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? 'Untitled Note' : note.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This action cannot be undone.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
