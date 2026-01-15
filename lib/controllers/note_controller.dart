import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/data/local/db_helper.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/lock_service.dart'; // 🔒 NEW
import 'package:note_app/services/notification_service.dart'; // 🔔 NEW
import 'package:note_app/services/pdf_export_service.dart'; // 📄 NEW

class NoteController extends GetxController {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();
  final LockService _lockService = Get.find<LockService>(); // 🔒 NEW
  final NotificationService _notificationService =
      Get.find<NotificationService>(); // 🔔 NEW

  final notes = <Note>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final searchedNotes = <Note>[].obs;
  final selectedTags = <String>[].obs; // 🏷️ NEW: Selected tags for filtering
  final allTags = <String>[].obs; // 🏷️ NEW: All available tags

  @override
  void onInit() {
    fetchNotes();
    loadAllTags(); // 🏷️ Load tags on init
    super.onInit();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      final notesList = await _dbHelper.getAllNotes();
      notes.assignAll(notesList);
      // Update searched notes when fetching all notes
      if (searchQuery.isNotEmpty) {
        await _performSearch(searchQuery.value);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notes: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // 🏷️ Load all available tags
  Future<void> loadAllTags() async {
    try {
      final tags = await _dbHelper.getAllTags();
      allTags.assignAll(tags);
    } catch (e) {
      print('Error loading tags: $e');
    }
  }

  // 🏷️ Search notes by tag
  Future<void> searchByTag(String tag) async {
    try {
      isLoading(true);
      final results = await _dbHelper.searchNotesByTag(tag);
      searchedNotes.assignAll(results);
      searchQuery.value = '#$tag';
    } catch (e) {
      Get.snackbar('Error', 'Tag search failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // 🏷️ Toggle tag filter
  void toggleTagFilter(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    applyTagFilters();
  }

  // 🏷️ Apply tag filters
  void applyTagFilters() {
    if (selectedTags.isEmpty) {
      fetchNotes();
      return;
    }

    final filtered =
        notes.where((note) {
          return selectedTags.every((tag) => note.tags.contains(tag));
        }).toList();

    searchedNotes.assignAll(filtered);
  }

  // 🔒 Toggle lock status
  Future<void> toggleLock(int id) async {
    try {
      final note = notes.firstWhere((note) => note.id == id);

      // If locking the note, require authentication
      if (!note.isLocked) {
        final authenticated = await _lockService.authenticateToUnlockNote(
          noteId: id,
          customReason: 'Authenticate to lock this note',
        );

        if (!authenticated) return;
      }

      await _dbHelper.toggleLockStatus(id, !note.isLocked);
      await fetchNotes();

      Get.snackbar('Success', note.isLocked ? 'Note unlocked' : 'Note locked');
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle lock: ${e.toString()}');
    }
  }

  // 🔒 Check if note can be viewed (handle locked notes)
  Future<bool> canViewNote(Note note) async {
    if (!note.isLocked) return true;

    // Check if already unlocked in session
    if (_lockService.isNoteUnlockedInSession(note.id!)) {
      return true;
    }

    // Request authentication
    return await _lockService.authenticateToUnlockNote(
      noteId: note.id!,
      customReason: 'Unlock "${note.title}"',
    );
  }

  // 📌 Set reminder for note
  Future<void> setReminder(Note note, DateTime reminderDate) async {
    try {
      // Update note with reminder date
      final updatedNote = note.copyWith(reminderDate: reminderDate);
      await _dbHelper.updateNote(updatedNote);

      // Schedule notification
      await _notificationService.scheduleReminder(
        noteId: note.id!,
        noteTitle: note.title,
        reminderDate: reminderDate,
        noteContent: note.content,
      );

      await fetchNotes();
      Get.snackbar('Success', 'Reminder set successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to set reminder: ${e.toString()}');
    }
  }

  // 📌 Cancel reminder
  Future<void> cancelReminder(Note note) async {
    try {
      // Remove reminder from note
      final updatedNote = note.copyWith(reminderDate: null);
      await _dbHelper.updateNote(updatedNote);

      // Cancel notification
      await _notificationService.cancelReminder(note.id!);

      await fetchNotes();
      Get.snackbar('Success', 'Reminder cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel reminder: ${e.toString()}');
    }
  }

  // 📌 Get notes with upcoming reminders
  Future<List<Note>> getUpcomingReminders() async {
    try {
      return await _dbHelper.getUpcomingReminders();
    } catch (e) {
      print('Error getting upcoming reminders: $e');
      return [];
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _dbHelper.createNote(note);
      await fetchNotes();
      Get.snackbar('Success', 'Note added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add note: ${e.toString()}');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _dbHelper.updateNote(note);
      await fetchNotes();
      Get.snackbar('Success', 'Note updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note: ${e.toString()}');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _dbHelper.deleteNote(id);
      await fetchNotes();
      Get.snackbar('Success', 'Note deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note: ${e.toString()}');
    }
  }

  Future<void> togglePin(int id) async {
    try {
      final note = notes.firstWhere((note) => note.id == id);
      await _dbHelper.togglePinStatus(id, !note.isPinned);
      await fetchNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle pin status: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final note = notes.firstWhere((note) => note.id == id);
      await _dbHelper.toggleFavoriteStatus(id, !note.isFavorite);
      await fetchNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle favorite: ${e.toString()}');
    }
  }

  Future<void> searchNotes(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchedNotes.clear();
      await fetchNotes();
    } else {
      await _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      isLoading(true);
      final results = await _dbHelper.searchNotes(query);
      searchedNotes.assignAll(results);
    } catch (e) {
      Get.snackbar('Error', 'Search failed: ${e.toString()}');
      searchedNotes.clear();
    } finally {
      isLoading(false);
    }
  }

  List<Note> get filteredNotes {
    if (selectedCategory.value == 'All') {
      return notes;
    }
    return notes
        .where((note) => note.category == selectedCategory.value)
        .toList();
  }

  List<Note> get displayedNotes {
    if (searchQuery.isNotEmpty) {
      // Apply category filter to search results if needed
      if (selectedCategory.value != 'All') {
        return searchedNotes
            .where((note) => note.category == selectedCategory.value)
            .toList();
      }
      return searchedNotes;
    }
    return filteredNotes;
  }

  Future<void> refreshNotes() async {
    await fetchNotes();
  }

  // 📄 Export multiple notes to PDF
  Future<void> exportNotesToPdf(
    List<Note> notesToExport,
    String fileName,
  ) async {
    if (notesToExport.isEmpty) {
      Get.snackbar(
        'Info',
        'No notes to export',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await PdfExportService.instance.exportMultipleNotesToPdf(
        notesToExport,
        fileName,
      );
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 📄 Export all notes to PDF
  Future<void> exportAllNotesToPdf() async {
    await exportNotesToPdf(notes, 'All_Notes');
  }

  // 📄 Export favorite notes to PDF
  Future<void> exportFavoriteNotesToPdf() async {
    final favoriteNotes = notes.where((note) => note.isFavorite).toList();
    await exportNotesToPdf(favoriteNotes, 'Favorite_Notes');
  }

  // 📄 Export notes by category to PDF
  Future<void> exportCategoryNotesToPdf(String category) async {
    final categoryNotes =
        notes.where((note) => note.category == category).toList();
    await exportNotesToPdf(categoryNotes, '${category}_Notes');
  }
}
