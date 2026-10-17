import 'package:drift/drift.dart';
import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NotesRepository {
  NotesRepository(this.database);

  final AppDatabase database;

  Future<List<Note>> getAllNotes() async {
    final rows = await (database.select(
      database.notes,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return rows
        .map(
          (row) => Note(
            id: row.id,
            title: row.title,
            content: row.content,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<void> insertNote(Note note) async {
    await database
        .into(database.notes)
        .insert(
          NotesCompanion.insert(
            id: note.id,
            title: note.title,
            content: note.content,
            updatedAt: note.updatedAt,
          ),
        );
  }

  Future<void> updateNote(Note note) async {
    await (database.update(
      database.notes,
    )..where((row) => row.id.equals(note.id))).write(
      NotesCompanion(
        title: Value(note.title),
        content: Value(note.content),
        updatedAt: Value(note.updatedAt),
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    await (database.delete(
      database.notes,
    )..where((row) => row.id.equals(id))).go();
  }
}
