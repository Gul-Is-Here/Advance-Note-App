import 'package:note_app/models/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor to return the singleton instance
  factory DatabaseHelper() => _instance;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // 🔄 Updated version for migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // 🆕 Migration handler
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Create database tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT DEFAULT 'General',
        isPinned INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        isLocked INTEGER DEFAULT 0,
        tags TEXT DEFAULT '',
        reminderDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // 🆕 Migration from version 1 to 2
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for existing databases
      await db.execute(
        'ALTER TABLE notes ADD COLUMN isLocked INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT DEFAULT ""');
      await db.execute('ALTER TABLE notes ADD COLUMN reminderDate TEXT');
    }
  }

  // CRUD Operations

  Future<int> createNote(Note note) async {
    final db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<Note?> getNoteById(int id) async {
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

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> togglePinStatus(int id, bool isPinned) async {
    final db = await database;
    return await db.rawUpdate('UPDATE notes SET isPinned = ? WHERE id = ?', [
      isPinned ? 1 : 0,
      id,
    ]);
  }

  Future<void> toggleFavoriteStatus(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'notes',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔒 Toggle lock status
  Future<void> toggleLockStatus(int id, bool isLocked) async {
    final db = await database;
    await db.update(
      'notes',
      {'isLocked': isLocked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🏷️ Get all unique tags across all notes
  Future<List<String>> getAllTags() async {
    final db = await database;
    final maps = await db.query('notes', columns: ['tags']);
    final Set<String> tagSet = {};

    for (var map in maps) {
      final tagsString = map['tags'] as String?;
      if (tagsString != null && tagsString.isNotEmpty) {
        tagSet.addAll(tagsString.split(','));
      }
    }

    return tagSet.toList()..sort();
  }

  // 🏷️ Search notes by tag
  Future<List<Note>> searchNotesByTag(String tag) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  // 📌 Get notes with reminders
  Future<List<Note>> getNotesWithReminders() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'reminderDate IS NOT NULL',
      orderBy: 'reminderDate ASC',
    );
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  // 📌 Get upcoming reminders (next 7 days)
  Future<List<Note>> getUpcomingReminders() async {
    final db = await database;
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));

    final maps = await db.query(
      'notes',
      where:
          'reminderDate IS NOT NULL AND reminderDate >= ? AND reminderDate <= ?',
      whereArgs: [now.toIso8601String(), weekLater.toIso8601String()],
      orderBy: 'reminderDate ASC',
    );
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
