class Note {
  int? id;
  String title;
  String content;
  String category;
  bool isPinned;
  bool isFavorite;
  bool isLocked; // 🔒 NEW: Lock status
  List<String> tags; // 🏷️ NEW: Tags list
  DateTime? reminderDate; // 📌 NEW: Reminder timestamp
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    this.isPinned = false,
    this.isFavorite = false,
    this.isLocked = false, // 🔒 NEW
    this.tags = const [], // 🏷️ NEW
    this.reminderDate, // 📌 NEW
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isPinned': isPinned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'isLocked': isLocked ? 1 : 0, // 🔒 NEW
      'tags': tags.join(','), // 🏷️ NEW: Store as comma-separated string
      'reminderDate': reminderDate?.toIso8601String(), // 📌 NEW
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      isPinned: map['isPinned'] == 1,
      isFavorite: map['isFavorite'] == 1,
      isLocked: map['isLocked'] == 1, // 🔒 NEW
      tags:
          map['tags'] != null && map['tags'].toString().isNotEmpty
              ? map['tags'].toString().split(',')
              : [], // 🏷️ NEW
      reminderDate:
          map['reminderDate'] != null
              ? DateTime.parse(map['reminderDate'])
              : null, // 📌 NEW
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // 🆕 Helper method to copy note with modifications
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    bool? isFavorite,
    bool? isLocked,
    List<String>? tags,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      tags: tags ?? this.tags,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
