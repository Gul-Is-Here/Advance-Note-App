import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/utility/app_colors.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/note_card.dart';
import 'package:note_app/widgets/custom_app_bar.dart';

class AllNotesView extends StatefulWidget {
  const AllNotesView({super.key});

  @override
  State<AllNotesView> createState() => _AllNotesViewState();
}

class _AllNotesViewState extends State<AllNotesView> {
  final NoteController controller = Get.find<NoteController>();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date'; // 'date', 'title', 'category'
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredAndSortedNotes() {
    var notes = controller.notes.toList();

    // Apply search filter
    final searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      notes =
          notes.where((note) {
            return note.title.toLowerCase().contains(searchQuery) ||
                note.category.toLowerCase().contains(searchQuery);
          }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      notes =
          notes.where((note) => note.category == _selectedCategory).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'title':
        notes.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'category':
        notes.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      floatingActionButton: _buildFAB(theme),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: CustomAppBar(
                title: 'All Notes',
                subtitle: '',
                showThemeToggle: false,
                showBackButton: true,
              ),
            ),

            // Stats Card
            SliverToBoxAdapter(
              child: Obx(() {
                final totalNotes = controller.notes.length;
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalNotes',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalNotes == 1 ? 'Total Note' : 'Total Notes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
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
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
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

            // Filter Chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _buildFilterChip('All', isDark),
                    const SizedBox(width: 8),
                    _buildSortChip(
                      'Date',
                      'date',
                      Icons.calendar_today_rounded,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip(
                      'Title',
                      'title',
                      Icons.sort_by_alpha_rounded,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip(
                      'Category',
                      'category',
                      Icons.folder_rounded,
                      isDark,
                    ),
                  ],
                ),
              ),
            ),

            // Notes Grid/List
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  );
                }

                final filteredNotes = _getFilteredAndSortedNotes();

                if (filteredNotes.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    children: [
                      ...filteredNotes.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NoteCard(note: note),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedCategory == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color:
            isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _sortBy == value;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color:
            isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color:
            isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.15),
                      AppColors.primaryGreen.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  hasSearchQuery
                      ? Icons.search_off_rounded
                      : Icons.note_add_outlined,
                  size: 80,
                  color: AppColors.primaryGreen.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                hasSearchQuery ? 'No Results Found' : 'No Notes Yet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasSearchQuery
                    ? 'Try adjusting your search or filters'
                    : 'Tap the + button to create your first note',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              if (hasSearchQuery) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedCategory = 'All';
                    });
                  },
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('Clear Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.to(
          () => const CreateNoteView(preSelectedCategory: 'Personal'),
          transition: Transition.rightToLeft,
        );
      },
      backgroundColor: AppColors.primaryGreen,
      elevation: 8,
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      label: const Text(
        'New Note',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
