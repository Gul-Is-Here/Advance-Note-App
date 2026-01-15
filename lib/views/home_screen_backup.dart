// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:note_app/controllers/note_controller.dart';
// import 'package:note_app/controllers/theme_controller.dart';
// import 'package:note_app/models/note_model.dart';
// import 'package:note_app/utility/app_colors.dart';
// import 'package:note_app/utility/constants.dart';
// import 'package:note_app/views/create_view.dart';
// import 'package:note_app/widgets/banner_ad_widget.dart';
// import 'package:note_app/widgets/note_card.dart';

// class HomeView extends GetView<NoteController> {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   HomeView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
//       floatingActionButton: _buildFloatingActionButton(theme),
//       body: SafeArea(
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Modern Header
//             SliverToBoxAdapter(
//               child: _buildHeader(theme, isDark),
//             ),

//             // Search Bar
//             SliverToBoxAdapter(
//               child: _buildSearchBar(theme, isDark),
//             ),

//             // Categories Section
//             SliverToBoxAdapter(
//               child: _buildCategoriesSection(theme, isDark),
//             ),

//             // Recent Notes Section
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Recent Notes',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     Obx(
//                       () => Text(
//                         '${controller.filteredNotes.length} notes',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Notes List
//             _buildNotesList(theme, isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(ThemeData theme, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Find The Best',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//               Text(
//                 'Notes For You',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           // Menu Button
//           Container(
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey[800] : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.menu_rounded,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//               onPressed: () {
//                 // Open menu/settings
//                 Get.find<ThemeController>().toggleTheme();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(ThemeData theme, bool isDark) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey[800] : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         style: TextStyle(
//           fontSize: 16,
//           color: isDark ? Colors.white : Colors.black87,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search Notes',
//           hintStyle: TextStyle(
//             color: isDark ? Colors.grey[400] : Colors.grey[500],
//             fontSize: 16,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             color: isDark ? Colors.grey[400] : Colors.grey[600],
//             size: 24,
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//         onChanged: (value) {
//           controller.searchQuery.value = value;
//           controller.searchNotes(value);
//         },
//       ),
//     );
//   }

//   Widget _buildCategoriesSection(ThemeData theme, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20, bottom: 16),
//             child: Text(
//               'Categories',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 140,
//             child: Obx(
//               () => ListView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(right: 20),
//                 children: [
//                   _buildCategoryCard(
//                     'All',
//                     Icons.grid_view_rounded,
//                     AppColors.primaryGreen,
//                     controller.selectedCategory.value == 'All',
//                     theme,
//                     isDark,
//                   ),
//                   _buildCategoryCard(
//                     'Work',
//                     Icons.work_outline_rounded,
//                     AppColors.info,
//                     controller.selectedCategory.value == 'Work',
//                     theme,
//                     isDark,
//                   ),
//                   _buildCategoryCard(
//                     'Personal',
//                     Icons.person_outline_rounded,
//                     AppColors.secondary,
//                     controller.selectedCategory.value == 'Personal',
//                     theme,
//                     isDark,
//                   ),
//                   _buildCategoryCard(
//                     'Ideas',
//                     Icons.lightbulb_outline_rounded,
//                     AppColors.warning,
//                     controller.selectedCategory.value == 'Ideas',
//                     theme,
//                     isDark,
//                   ),
//                   _buildCategoryCard(
//                     'Todo',
//                     Icons.check_circle_outline_rounded,
//                     AppColors.success,
//                     controller.selectedCategory.value == 'Todo',
//                     theme,
//                     isDark,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryCard(
//     String title,
//     IconData icon,
//     Color color,
//     bool isSelected,
//     ThemeData theme,
//     bool isDark,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         controller.filterByCategory(title);
//       },
//       child: Container(
//         width: 120,
//         margin: const EdgeInsets.only(left: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? color.withOpacity(0.15)
//               : isDark
//                   ? Colors.grey[800]
//                   : Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isSelected ? color : Colors.transparent,
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
//                 color: isSelected
//                     ? color
//                     : isDark
//                         ? Colors.white
//                         : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotesList(ThemeData theme, bool isDark) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return SliverFillRemaining(
//           child: Center(
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
//             ),
//           ),
//         );
//       }

//       final notesToDisplay = _searchController.text.isNotEmpty
//           ? controller.searchedNotes
//           : controller.filteredNotes;

//       if (notesToDisplay.isEmpty) {
//         return SliverFillRemaining(
//           child: _buildEmptyState(theme, isDark),
//         );
//       }

//       return SliverPadding(
//         padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
//         sliver: SliverList(
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               if (index >= notesToDisplay.length) return null;
//               final note = notesToDisplay[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: _buildNoteCard(note, theme, isDark),
//               );
//             },
//             childCount: notesToDisplay.length,
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildNoteCard(Note note, ThemeData theme, bool isDark) {
//     return NoteCard(note: note, onDelete: controller.deleteNote);
//   }

//   Widget _buildEmptyState(ThemeData theme, bool isDark) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryGreen.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.note_add_outlined,
//                 size: 80,
//                 color: AppColors.primaryGreen.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No notes yet',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Tap the + button to create your first note',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isDark ? Colors.grey[400] : Colors.grey[600],
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton(ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 70),
//       child: FloatingActionButton.extended(
//         onPressed: () {
//           Get.to(
//             () => CreateNoteView(),
//             transition: Transition.rightToLeft,
//             duration: const Duration(milliseconds: 300),
//           );
//         },
//         backgroundColor: AppColors.primaryGreen,
//         elevation: 8,
//         icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
//         label: const Text(
//           'New Note',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
//       floatingActionButton: Obx(
//         () => AnimatedScale(
//           scale: _fabHovered.value ? 1.05 : 1.0,
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOut,
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 70),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: [
//                 BoxShadow(
//                   color: theme.colorScheme.primary.withOpacity(0.4),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                   spreadRadius: 2,
//                 ),
//                 BoxShadow(
//                   color: theme.colorScheme.primary.withOpacity(0.2),
//                   blurRadius: 40,
//                   offset: const Offset(0, 12),
//                   spreadRadius: 4,
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   _fabHovered.value = false;
//                   Get.to(
//                     () => CreateNoteView(),
//                     transition: Transition.rightToLeft,
//                     duration: const Duration(milliseconds: 300),
//                   );
//                 },
//                 onTapDown: (_) => _fabHovered.value = true,
//                 onTapUp: (_) => _fabHovered.value = false,
//                 onTapCancel: () => _fabHovered.value = false,
//                 borderRadius: BorderRadius.circular(30),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.primary.withOpacity(0.8),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.add_rounded,
//                           size: 24,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'New Note',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.5,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Obx(
//         () => CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Modern App Bar with Gradient
//             SliverAppBar(
//               expandedHeight: 140,
//               floating: true,
//               pinned: true,
//               snap: false,
//               elevation: 0,
//               backgroundColor: Colors.transparent,
//               flexibleSpace: FlexibleSpaceBar(
//                 centerTitle: false,
//                 titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
//                 title: Obx(
//                   () => Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         controller.selectedCategory.value == 'All'
//                             ? 'My Notes'
//                             : controller.selectedCategory.value,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '${controller.filteredNotes.length} notes',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.white.withOpacity(0.9),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 background: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.primaryContainer,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         right: -30,
//                         top: -30,
//                         child: Container(
//                           width: 150,
//                           height: 150,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: -50,
//                         bottom: -50,
//                         child: Container(
//                           width: 200,
//                           height: 200,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.05),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 // Search Button
//                 IconButton(
//                   icon: Icon(
//                     _showSearchBar.value
//                         ? Icons.close_rounded
//                         : Icons.search_rounded,
//                     color: Colors.white,
//                     size: 26,
//                   ),
//                   onPressed: () {
//                     _searchController.clear();
//                     controller.searchQuery.value = '';
//                     _showSearchBar.toggle();
//                   },
//                 ),
//                 // Category Filter
//                 _buildCategoryFilter(theme, isDark),
//                 // Theme Toggle
//                 Obx(
//                   () => IconButton(
//                     icon: Icon(
//                       Get.find<ThemeController>().isDarkMode.value
//                           ? Icons.light_mode_rounded
//                           : Icons.dark_mode_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                     onPressed: () => Get.find<ThemeController>().toggleTheme(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//             // Modern Search Bar
//             if (_showSearchBar.value)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[850] : Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             isDark
//                                 ? Colors.black.withOpacity(0.3)
//                                 : Colors.grey.withOpacity(0.2),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     autofocus: true,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Search your notes...',
//                       hintStyle: TextStyle(
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         fontSize: 16,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: theme.colorScheme.primary,
//                         size: 24,
//                       ),
//                       suffixIcon:
//                           _searchController.text.isNotEmpty
//                               ? IconButton(
//                                 icon: Icon(
//                                   Icons.clear_rounded,
//                                   color: Colors.grey[600],
//                                 ),
//                                 onPressed: () {
//                                   _searchController.clear();
//                                   controller.searchQuery.value = '';
//                                 },
//                               )
//                               : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       controller.searchQuery.value = value;
//                       controller.searchNotes(value);
//                     },
//                   ),
//                 ),
//               ),
//             // Loading State
//             Obx(() {
//               if (controller.isLoading.value) {
//                 return SliverFillRemaining(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           strokeWidth: 3,
//                           valueColor: AlwaysStoppedAnimation(
//                             theme.colorScheme.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Loading notes...',
//                           style: TextStyle(
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }

//               final notesToDisplay =
//                   _showSearchBar.value && _searchController.text.isNotEmpty
//                       ? controller.searchedNotes
//                       : controller.filteredNotes;

//               // Empty State
//               if (notesToDisplay.isEmpty) {
//                 return SliverFillRemaining(
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(32),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.primary.withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               _showSearchBar.value &&
//                                       _searchController.text.isNotEmpty
//                                   ? Icons.search_off_rounded
//                                   : Icons.note_add_outlined,
//                               size: 80,
//                               color: theme.colorScheme.primary.withOpacity(0.6),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           Text(
//                             _showSearchBar.value &&
//                                     _searchController.text.isNotEmpty
//                                 ? 'No results found'
//                                 : 'No notes yet',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             _showSearchBar.value &&
//                                     _searchController.text.isNotEmpty
//                                 ? 'Try searching with different keywords'
//                                 : 'Tap the button below to create your first note',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color:
//                                   isDark ? Colors.grey[400] : Colors.grey[600],
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               // Notes Grid
//               return SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       // Calculate ad positions
//                       final adInterval = 3;
//                       final isAdPosition = (index + 1) % (adInterval + 1) == 0;

//                       if (isAdPosition && index != 0) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           child: const BannerAdWidget(),
//                         );
//                       }

//                       final noteIndex = index - (index ~/ (adInterval + 1));

//                       if (noteIndex >= notesToDisplay.length) {
//                         return const SizedBox.shrink();
//                       }

//                       final note = notesToDisplay[noteIndex];

//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         child: Dismissible(
//                           key: Key(note.id.toString()),
//                           direction: DismissDirection.endToStart,
//                           confirmDismiss: (direction) async {
//                             return await _showDeleteConfirmation(context, note);
//                           },
//                           background: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.red.shade400,
//                                   Colors.red.shade600,
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.only(right: 28),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.delete_rounded,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Delete',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onDismissed:
//                               (direction) => controller.deleteNote(note.id!),
//                           child: NoteCard(note: note),
//                         ),
//                       );
//                     },
//                     childCount:
//                         notesToDisplay.length + (notesToDisplay.length ~/ 3),
//                   ),
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilter(ThemeData theme, bool isDark) {
//     return PopupMenuButton(
//       icon: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Icon(
//           Icons.filter_list_rounded,
//           color: Colors.white,
//           size: 22,
//         ),
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 8,
//       offset: const Offset(0, 10),
//       color: isDark ? Colors.grey[850] : Colors.white,
//       itemBuilder:
//           (context) =>
//               AppConstants.categories.map((category) {
//                 final isSelected =
//                     controller.selectedCategory.value == category;
//                 return PopupMenuItem(
//                   value: category,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color:
//                                 isSelected
//                                     ? theme.colorScheme.primary.withOpacity(0.2)
//                                     : Colors.transparent,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Icon(
//                             _getCategoryIcon(category),
//                             color:
//                                 isSelected
//                                     ? theme.colorScheme.primary
//                                     : (isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[700]),
//                             size: 22,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             category,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight:
//                                   isSelected
//                                       ? FontWeight.w600
//                                       : FontWeight.w500,
//                               color:
//                                   isSelected
//                                       ? theme.colorScheme.primary
//                                       : (isDark
//                                           ? Colors.white
//                                           : Colors.black87),
//                             ),
//                           ),
//                         ),
//                         if (isSelected)
//                           Icon(
//                             Icons.check_circle_rounded,
//                             color: theme.colorScheme.primary,
//                             size: 20,
//                           ),
//                       ],
//                     ),
//                   ),
//                   onTap: () => controller.selectedCategory.value = category,
//                 );
//               }).toList(),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'All':
//         return Icons.dashboard_rounded;
//       case 'Work':
//         return Icons.work_rounded;
//       case 'Personal':
//         return Icons.person_rounded;
//       case 'Ideas':
//         return Icons.lightbulb_rounded;
//       case 'To-Do':
//         return Icons.check_circle_rounded;
//       case 'General':
//         return Icons.note_rounded;
//       default:
//         return Icons.folder_rounded;
//     }
//   }

//   Future<bool?> _showDeleteConfirmation(BuildContext context, Note note) async {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24),
//             ),
//             backgroundColor: isDark ? Colors.grey[850] : Colors.white,
//             elevation: 16,
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Icon
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.delete_forever_rounded,
//                       color: Colors.red.shade500,
//                       size: 48,
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Title
//                   Text(
//                     'Delete Note?',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Message
//                   Text(
//                     'This note will be permanently deleted.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Note Preview
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[800] : Colors.grey[100],
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           note.title.isEmpty ? 'Untitled Note' : note.title,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: theme.colorScheme.primary.withOpacity(
//                                   0.1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 note.category,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.of(context).pop(false),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             side: BorderSide(
//                               color:
//                                   isDark
//                                       ? Colors.grey[700]!
//                                       : Colors.grey[300]!,
//                               width: 2,
//                             ),
//                           ),
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   isDark ? Colors.grey[300] : Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.of(context).pop(true),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade500,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.delete_rounded, size: 20),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Delete',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }
// }
