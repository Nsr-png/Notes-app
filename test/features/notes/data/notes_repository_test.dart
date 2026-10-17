import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/data/notes_repository.dart';
import 'package:notes_app/features/notes/domain/note.dart';

void main() {
  late AppDatabase database;
  late NotesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = NotesRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('insère une note puis la lit', () async {
    final note = _note('note-1', 'Première note', DateTime(2025));

    await repository.insertNote(note);

    expect(await repository.getAllNotes(), [note]);
  });

  test('trie les notes par date décroissante', () async {
    final older = _note('note-1', 'Ancienne', DateTime(2025));
    final newer = _note('note-2', 'Récente', DateTime(2026));
    await repository.insertNote(older);
    await repository.insertNote(newer);

    expect(await repository.getAllNotes(), [newer, older]);
  });

  test('met à jour une note', () async {
    final note = _note('note-1', 'Avant', DateTime(2025));
    final updatedNote = Note(
      id: note.id,
      title: 'Après',
      content: 'Contenu modifié',
      updatedAt: DateTime(2026),
    );
    await repository.insertNote(note);

    await repository.updateNote(updatedNote);

    expect(await repository.getAllNotes(), [updatedNote]);
  });

  test('supprime une note', () async {
    final note = _note('note-1', 'À supprimer', DateTime(2025));
    await repository.insertNote(note);

    await repository.deleteNote(note.id);

    expect(await repository.getAllNotes(), isEmpty);
  });

  test('supprimer un identifiant inconnu ne génère pas d’erreur', () async {
    await expectLater(repository.deleteNote('unknown'), completes);
    expect(await repository.getAllNotes(), isEmpty);
  });
}

Note _note(String id, String title, DateTime updatedAt) {
  return Note(
    id: id,
    title: title,
    content: 'Contenu de $title',
    updatedAt: updatedAt,
  );
}
