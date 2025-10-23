class Note {
  int? id;
  String title;
  String content;
  String category;
  bool isPinned;
  bool isFavorite; // ✅ NEW
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    this.isPinned = false,
    this.isFavorite = false, // ✅ NEW
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isPinned': isPinned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0, // ✅
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
      isFavorite: map['isFavorite'] == 1, // ✅
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
