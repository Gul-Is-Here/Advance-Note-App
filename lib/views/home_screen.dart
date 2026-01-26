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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  NoteController get controller => Get.find<NoteController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      floatingActionButton: _buildEnhancedFAB(theme, isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated gradient background decoration
            if (!isDark) _buildBackgroundDecoration(),

            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Enhanced Greeting Header
                    SliverToBoxAdapter(
                      child: _buildEnhancedHeader(theme, isDark),
                    ),

                    // Quick Stats Card
                    SliverToBoxAdapter(
                      child: _buildQuickStatsCard(theme, isDark),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: _buildModernSearchBar(theme, isDark),
                    ),

                    // Folders Section
                    SliverToBoxAdapter(
                      child: _buildCategoriesSection(theme, isDark),
                    ),

                    // History Section
                    SliverToBoxAdapter(
                      child: _buildHistorySection(theme, isDark),
                    ),

                    // Add some bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),

            // Scroll to top button
            if (_showScrollToTop)
              Positioned(
                right: 20,
                bottom: 90,
                child: _buildScrollToTopButton(theme, isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primaryGreen.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What would you like to note today?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Theme toggle button with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.changeThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          );
                        },
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌆';
    return 'Good Night 🌙';
  }

  Widget _buildQuickStatsCard(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final totalNotes = controller.notes.length;
        final todayNotes =
            controller.notes
                .where(
                  (note) =>
                      note.createdAt.day == DateTime.now().day &&
                      note.createdAt.month == DateTime.now().month &&
                      note.createdAt.year == DateTime.now().year,
                )
                .length;
        final pinnedNotes =
            controller.notes.where((note) => note.isPinned).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Notes',
              totalNotes.toString(),
              Icons.description_rounded,
            ),
            _buildStatDivider(),
            _buildStatItem('Today', todayNotes.toString(), Icons.today_rounded),
            _buildStatDivider(),
            _buildStatItem(
              'Pinned',
              pinnedNotes.toString(),
              Icons.push_pin_rounded,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildModernSearchBar(ThemeData theme, bool isDark) {
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
          hintText: 'Search your notes...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryGreen,
            size: 24,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.searchQuery.value = '';
                      controller.searchNotes('');
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
          controller.searchNotes(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildScrollToTopButton(ThemeData theme, bool isDark) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              );
            },
            child: Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.primaryGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedFAB(ThemeData theme, bool isDark) {
    return Obx(() {
      final category =
          controller.selectedCategory.value == 'All'
              ? 'Personal'
              : controller.selectedCategory.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(
              () => CreateNoteView(preSelectedCategory: category),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: Text(
            'New Note',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    });
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Folders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
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

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color:
                    isSelected
                        ? null
                        : (isDark ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? color.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 20 : 10,
                    offset: Offset(0, isSelected ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Folder icon with animated background
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.rotate(
                              angle: value * 0.1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withOpacity(0.2),
                                      color.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                            );
                          },
                        ),
                      ),
                      // Note count badge
                      if (noteCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            noteCount.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Folder info
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Notes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to All Notes view
                  Get.to(
                    () => const AllNotesView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                label: Text(
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
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your notes...',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
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
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_add_rounded,
                          size: 48,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start creating your first note!',
                        style: TextStyle(
                          fontSize: 14,
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
                  displayNotes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final note = entry.value;
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: NoteCard(note: note),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
