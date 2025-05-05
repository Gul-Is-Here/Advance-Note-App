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
  final RxBool _showSearchBar = false.obs; // Changed to RxBool

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton(
          backgroundColor: Colors.pink,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () => Get.to(() => CreateNoteView()),
        ),
      ),
      body: Obx(
        () => CustomScrollView(
          // Wrap with Obx
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: false,
              elevation: 4,
              backgroundColor: theme.appBarTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Obx(
                  () => Text(
                    controller.selectedCategory.value == 'All'
                        ? 'All Notes'
                        : '${controller.selectedCategory.value} Notes',
                    style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [Colors.grey.shade900, Colors.black]
                              : [Colors.pinkAccent, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchQuery.value = '';
                    _showSearchBar.toggle(); // Use toggle instead of setState
                  },
                ),
                _buildCategoryFilter(),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      Get.find<ThemeController>().isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.find<ThemeController>().toggleTheme(),
                  ),
                ),
              ],
            ),

            if (_showSearchBar.value) // Use .value to access the bool
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blueGrey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        prefixIcon: Icon(Icons.search, color: theme.hintColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
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
                          color: theme.hintColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _showSearchBar.value &&
                                  _searchController.text.isNotEmpty
                              ? 'No results found'
                              : 'No notes yet!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _showSearchBar.value &&
                                  _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Tap the + button to create your first note',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = notesToDisplay[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Dismissible(
                        key: Key(note.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed:
                            (direction) => controller.deleteNote(note.id!),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 100),
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

  Widget _buildCategoryFilter() {
    return PopupMenuButton(
      icon: Icon(Icons.filter_list),
      itemBuilder:
          (context) =>
              AppConstants.categories.map((category) {
                return PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), color: Colors.white),
                      SizedBox(width: 12),
                      Text(category),
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
