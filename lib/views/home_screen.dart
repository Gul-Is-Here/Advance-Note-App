import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/utility/constants.dart';
import 'package:note_app/views/create_view.dart';
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
          child: const Icon(Icons.add),
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
                          color: Colors.black.withOpacity(0.1),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = notesToDisplay[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Dismissible(
                        key: Key(note.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed:
                            (direction) => controller.deleteNote(note.id!),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 100),
                          child: NoteCard(note: note),
                        ),
                      ),
                    );
                  }, childCount: notesToDisplay.length),
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
}
