import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'modern_notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            isPinned INTEGER,
            isArchived INTEGER,
            tags TEXT
          )
        ''');
      },
    );
  }

  // Create
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Read
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'isPinned DESC, updatedAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> togglePinStatus(String id, bool isPinned) async {
    final db = await database;
    return await db.update(
      'notes',
      {'isPinned': isPinned ? 1 : 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleArchiveStatus(String id, bool isArchived) async {
    final db = await database;
    return await db.update(
      'notes',
      {'isArchived': isArchived ? 1 : 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> deleteNote(String id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllArchivedNotes() async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'isArchived = ?',
      whereArgs: [1],
    );
  }

  // Search
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return getAllNotes();
    
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%,$query,%'],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Tags
  Future<List<String>> getAllTags() async {
    final db = await database;
    final notes = await db.query('notes');
    final allTags = <String>{};
    
    for (final note in notes) {
      final tags = note['tags'].toString().split(',').where((t) => t.isNotEmpty);
      allTags.addAll(tags);
    }
    
    return allTags.toList();
  }

  Future<List<Note>> getNotesByTag(String tag) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'tags LIKE ?',
      whereArgs: ['%,$tag,%'],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Backup/Restore
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}