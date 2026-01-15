import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/note_card.dart';

class FolderDetailView extends StatefulWidget {
  final String folderName;
  final String category;
  final Color folderColor;
  final IconData folderIcon;

  const FolderDetailView({
    super.key,
    required this.folderName,
    required this.category,
    required this.folderColor,
    required this.folderIcon,
  });

  @override
  State<FolderDetailView> createState() => _FolderDetailViewState();
}

class _FolderDetailViewState extends State<FolderDetailView> {
  final NoteController controller = Get.find<NoteController>();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date'; // 'date', 'title'
  String _viewMode = 'list'; // 'list', 'grid'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredAndSortedNotes() {
    var notes =
        widget.category == 'All'
            ? controller.notes.toList()
            : controller.notes
                .where((note) => note.category == widget.category)
                .toList();

    // Apply search filter
    final searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      notes =
          notes.where((note) {
            return note.title.toLowerCase().contains(searchQuery);
          }).toList();
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
            // Back button and title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Folder info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folderName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final count =
                                widget.category == 'All'
                                    ? controller.notes.length
                                    : controller.notes
                                        .where(
                                          (note) =>
                                              note.category == widget.category,
                                        )
                                        .length;
                            return Text(
                              '$count ${count == 1 ? 'note' : 'notes'}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    // Menu button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'sort_date':
                              setState(() => _sortBy = 'date');
                              break;
                            case 'sort_title':
                              setState(() => _sortBy = 'title');
                              break;
                            case 'view_list':
                              setState(() => _viewMode = 'list');
                              break;
                            case 'view_grid':
                              setState(() => _viewMode = 'grid');
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'sort_date',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 20,
                                      color:
                                          _sortBy == 'date'
                                              ? widget.folderColor
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sort by Date',
                                      style: TextStyle(
                                        color:
                                            _sortBy == 'date'
                                                ? widget.folderColor
                                                : null,
                                        fontWeight:
                                            _sortBy == 'date'
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                    if (_sortBy == 'date') ...[
                                      const Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: widget.folderColor,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'sort_title',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha_rounded,
                                      size: 20,
                                      color:
                                          _sortBy == 'title'
                                              ? widget.folderColor
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sort by Title',
                                      style: TextStyle(
                                        color:
                                            _sortBy == 'title'
                                                ? widget.folderColor
                                                : null,
                                        fontWeight:
                                            _sortBy == 'title'
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                    if (_sortBy == 'title') ...[
                                      const Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: widget.folderColor,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'view_list',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_rounded,
                                      size: 20,
                                      color:
                                          _viewMode == 'list'
                                              ? widget.folderColor
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'List View',
                                      style: TextStyle(
                                        color:
                                            _viewMode == 'list'
                                                ? widget.folderColor
                                                : null,
                                        fontWeight:
                                            _viewMode == 'list'
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                    if (_viewMode == 'list') ...[
                                      const Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: widget.folderColor,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'view_grid',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 20,
                                      color:
                                          _viewMode == 'grid'
                                              ? widget.folderColor
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Grid View',
                                      style: TextStyle(
                                        color:
                                            _viewMode == 'grid'
                                                ? widget.folderColor
                                                : null,
                                        fontWeight:
                                            _viewMode == 'grid'
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                    if (_viewMode == 'grid') ...[
                                      const Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: widget.folderColor,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Folder icon banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.folderColor,
                      widget.folderColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.folderColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.folderIcon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folderName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                    hintText: 'Search in ${widget.folderName}...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: widget.folderColor,
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

            // Sort and View Mode indicator
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sort indicator
                    Row(
                      children: [
                        Icon(
                          _sortBy == 'date'
                              ? Icons.calendar_today_rounded
                              : Icons.sort_by_alpha_rounded,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sortBy == 'date'
                              ? 'Sorted by Date'
                              : 'Sorted by Title',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    // View mode indicator
                    Row(
                      children: [
                        Icon(
                          _viewMode == 'list'
                              ? Icons.list_rounded
                              : Icons.grid_view_rounded,
                          size: 16,
                          color: widget.folderColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _viewMode == 'list' ? 'List View' : 'Grid View',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.folderColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Notes List/Grid
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(widget.folderColor),
                      ),
                    ),
                  );
                }

                final filteredNotes = _getFilteredAndSortedNotes();

                if (filteredNotes.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                // List View
                if (_viewMode == 'list') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      children:
                          filteredNotes
                              .map(
                                (note) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: NoteCard(note: note),
                                ),
                              )
                              .toList(),
                    ),
                  );
                }

                // Grid View
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(note: filteredNotes[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
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
                      widget.folderColor.withOpacity(0.15),
                      widget.folderColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.folderColor.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  hasSearchQuery ? Icons.search_off_rounded : widget.folderIcon,
                  size: 80,
                  color: widget.folderColor.withOpacity(0.7),
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
                    ? 'Try adjusting your search'
                    : 'Tap the + button to add your first note to ${widget.folderName}',
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
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.folderColor,
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
          () => CreateNoteView(
            preSelectedCategory:
                widget.category == 'All' ? 'Personal' : widget.category,
          ),
          transition: Transition.rightToLeft,
        );
      },
      backgroundColor: widget.folderColor,
      elevation: 8,
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      label: const Text(
        'Add Note',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
