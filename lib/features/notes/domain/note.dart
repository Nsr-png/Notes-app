class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, title, content, updatedAt);
}
