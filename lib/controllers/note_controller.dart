import 'package:get/get.dart';
import 'package:note_app/data/local/db_helper.dart';
import 'package:note_app/models/note_model.dart';

class NoteController extends GetxController {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();
  final notes = <Note>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final searchedNotes = <Note>[].obs; // Add this line for search results

  @override
  void onInit() {
    fetchNotes();
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

  Future<void> addNote(Note note) async {
    try {
      await _dbHelper.createNote(note);
      await fetchNotes();
      Get.back(); // Close create/edit screen
      Get.snackbar('Success', 'Note added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add note: ${e.toString()}');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _dbHelper.updateNote(note);
      await fetchNotes();
      Get.back(); // Close create/edit screen
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
    return notes.where((note) => note.category == selectedCategory.value).toList();
  }

  List<Note> get displayedNotes {
    if (searchQuery.isNotEmpty) {
      // Apply category filter to search results if needed
      if (selectedCategory.value != 'All') {
        return searchedNotes.where((note) => note.category == selectedCategory.value).toList();
      }
      return searchedNotes;
    }
    return filteredNotes;
  }

  Future<void> refreshNotes() async {
    await fetchNotes();
  }
}