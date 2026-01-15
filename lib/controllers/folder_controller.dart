import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FolderController extends GetxController {
  // Default folders that cannot be deleted
  final List<Map<String, dynamic>> defaultFolders = [
    {
      'title': 'All Notes',
      'icon': Icons.folder_rounded,
      'color': 0xFF08C27B, // AppColors.primaryGreen
      'category': 'All',
      'isDefault': true,
    },
    {
      'title': 'Work',
      'icon': Icons.work_rounded,
      'color': 0xFF2196F3, // AppColors.info
      'category': 'Work',
      'isDefault': true,
    },
    {
      'title': 'Personal',
      'icon': Icons.person_rounded,
      'color': 0xFF9C27B0, // AppColors.secondary
      'category': 'Personal',
      'isDefault': true,
    },
    {
      'title': 'Ideas',
      'icon': Icons.lightbulb_rounded,
      'color': 0xFFFFC107, // AppColors.warning
      'category': 'Ideas',
      'isDefault': true,
    },
    {
      'title': 'Todo',
      'icon': Icons.check_circle_rounded,
      'color': 0xFF4CAF50, // AppColors.success
      'category': 'Todo',
      'isDefault': true,
    },
  ];

  // Observable list of custom folders
  final RxList<Map<String, dynamic>> customFolders =
      <Map<String, dynamic>>[].obs;

  // All folders (default + custom)
  List<Map<String, dynamic>> get allFolders {
    return [...defaultFolders, ...customFolders];
  }

  // Available categories for dropdown
  List<String> get allCategories {
    return allFolders
        .where((folder) => folder['category'] != 'All')
        .map((folder) => folder['category'] as String)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomFolders();
  }

  // Load custom folders from SharedPreferences
  Future<void> loadCustomFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foldersJson = prefs.getString('custom_folders');

      if (foldersJson != null) {
        final List<dynamic> decoded = jsonDecode(foldersJson);
        customFolders.value =
            decoded.map((folder) {
              // Store icon codePoint as int, create IconData at display time
              final iconCodePoint = folder['icon'] as int;
              return {
                'title': folder['title'],
                'iconCodePoint':
                    iconCodePoint, // Store as int instead of IconData
                'color': folder['color'],
                'category': folder['category'],
                'isDefault': false,
              };
            }).toList();
      }
    } catch (e) {
      print('Error loading custom folders: $e');
    }
  }

  // Save custom folders to SharedPreferences
  Future<void> saveCustomFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foldersToSave =
          customFolders.map((folder) {
            // Get icon codePoint - handle both IconData and int
            final iconValue = folder['icon'];
            final int codePoint;
            if (iconValue is IconData) {
              codePoint = iconValue.codePoint;
            } else if (iconValue is int) {
              codePoint = iconValue;
            } else {
              // Try to get from iconCodePoint key
              codePoint =
                  folder['iconCodePoint'] as int? ??
                  0xe88a; // Default folder icon
            }

            return {
              'title': folder['title'],
              'icon': codePoint,
              'color': folder['color'],
              'category': folder['category'],
            };
          }).toList();

      await prefs.setString('custom_folders', jsonEncode(foldersToSave));
    } catch (e) {
      print('Error saving custom folders: $e');
    }
  }

  // Helper method to get IconData from codePoint
  IconData getIconData(Map<String, dynamic> folder) {
    if (folder.containsKey('icon') && folder['icon'] is IconData) {
      return folder['icon'] as IconData;
    } else if (folder.containsKey('iconCodePoint')) {
      return IconData(
        folder['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      );
    } else if (folder.containsKey('icon') && folder['icon'] is int) {
      return IconData(folder['icon'] as int, fontFamily: 'MaterialIcons');
    }
    return const IconData(
      0xe88a,
      fontFamily: 'MaterialIcons',
    ); // Default folder icon
  }

  // Add a new custom folder
  Future<bool> addFolder({
    required String title,
    required String category,
    required IconData icon,
    required int color,
  }) async {
    // Check if category already exists
    if (allCategories.contains(category)) {
      return false;
    }

    final newFolder = {
      'title': title,
      'icon': icon,
      'color': color,
      'category': category,
      'isDefault': false,
    };

    customFolders.add(newFolder);
    await saveCustomFolders();

    return true;
  }

  // Delete a custom folder (only custom folders can be deleted)
  Future<void> deleteFolder(String category) async {
    customFolders.removeWhere((folder) => folder['category'] == category);
    await saveCustomFolders();

    Get.snackbar(
      'Success',
      'Folder deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Update folder (only custom folders)
  Future<void> updateFolder({
    required String oldCategory,
    required String newTitle,
    required String newCategory,
    required IconData newIcon,
    required int newColor,
  }) async {
    final index = customFolders.indexWhere(
      (folder) => folder['category'] == oldCategory,
    );

    if (index != -1) {
      customFolders[index] = {
        'title': newTitle,
        'icon': newIcon,
        'color': newColor,
        'category': newCategory,
        'isDefault': false,
      };
      await saveCustomFolders();

      Get.snackbar(
        'Success',
        'Folder updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
