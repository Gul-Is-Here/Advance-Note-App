import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/folder_controller.dart';
import 'package:note_app/utility/app_colors.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/views/folder_detail_view.dart';
import 'package:note_app/views/all_notes_view.dart';
import 'package:note_app/widgets/note_card.dart';
import 'package:note_app/widgets/add_folder_dialog.dart';
import 'package:note_app/widgets/custom_app_bar.dart';

class HomeView extends GetView<NoteController> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      // floatingActionButton: _buildFloatingActionButton(theme),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Greeting Header
            SliverToBoxAdapter(
              child: CustomAppBar(
                title: '',
                subtitle: 'What would you like to note today?',
                showThemeToggle: true,
                showBackButton: false,
              ),
            ),

            // Search Bar
            // SliverToBoxAdapter(child: _buildSearchBar(theme, isDark)),

            // Folders Section
            SliverToBoxAdapter(child: _buildCategoriesSection(theme, isDark)),

            // History Section
            SliverToBoxAdapter(child: _buildHistorySection(theme, isDark)),

            // Add some bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
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
        controller: _searchController,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search Notes',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
          controller.searchNotes(value);
        },
      ),
    );
  }

  Widget _buildCategoriesSection(ThemeData theme, bool isDark) {
    final folderController = Get.find<FolderController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Folders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Show add folder dialog
                  Get.dialog(const AddFolderDialog());
                },
                icon: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                label: Text(
                  'New Folder',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final folders = folderController.allFolders;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final folderController = Get.find<FolderController>();
                return Obx(
                  () => _buildFolderCard(
                    folder['title'] as String,
                    folderController.getIconData(folder), // Use helper method
                    Color(folder['color'] as int),
                    folder['category'] as String,
                    controller.selectedCategory.value == folder['category'],
                    theme,
                    isDark,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFolderCard(
    String title,
    IconData icon,
    Color color,
    String category,
    bool isSelected,
    ThemeData theme,
    bool isDark,
  ) {
    // Calculate note count for this folder
    final noteCount =
        category == 'All'
            ? controller.notes.length
            : controller.notes
                .where((note) => note.category == category)
                .length;

    return GestureDetector(
      onTap: () {
        controller.selectedCategory.value = category;
        // Navigate to folder detail view
        Get.to(
          () => FolderDetailView(
            folderName: title,
            category: category,
            folderColor: color,
            folderIcon: icon,
          ),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Folder icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),

            const SizedBox(height: 8),

            // Folder info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to All Notes view
                  Get.to(
                    () => const AllNotesView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Get recent notes (last 5 notes sorted by update date)
            final recentNotes =
                controller.notes.toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            final displayNotes = recentNotes.take(5).toList();

            if (displayNotes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent notes',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children:
                  displayNotes.map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NoteCard(note: note),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return Obx(() {
      // Get the currently selected category (default to 'Personal' if 'All' is selected)
      final category =
          controller.selectedCategory.value == 'All'
              ? 'Personal'
              : controller.selectedCategory.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(
              () => CreateNoteView(preSelectedCategory: category),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          backgroundColor: AppColors.primaryGreen,
          elevation: 8,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: Text(
            controller.selectedCategory.value == 'All'
                ? 'New Note'
                : 'Add to ${controller.selectedCategory.value}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }
}
