import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/domain/note.dart';

void main() {
  final updatedAt = DateTime(2026, 10, 17);
  final note = Note(
    id: 'note-1',
    title: 'Titre',
    content: 'Contenu',
    updatedAt: updatedAt,
  );

  test('conserve les valeurs fournies', () {
    expect(note.id, 'note-1');
    expect(note.title, 'Titre');
    expect(note.content, 'Contenu');
    expect(note.updatedAt, updatedAt);
  });

  test('copyWith ne modifie que le champ demandé', () {
    final updatedNote = note.copyWith(content: 'Nouveau contenu');

    expect(
      updatedNote,
      Note(
        id: note.id,
        title: note.title,
        content: 'Nouveau contenu',
        updatedAt: note.updatedAt,
      ),
    );
  });

  test('deux notes avec les mêmes valeurs sont égales', () {
    final sameNote = Note(
      id: 'note-1',
      title: 'Titre',
      content: 'Contenu',
      updatedAt: updatedAt,
    );

    expect(note, sameNote);
    expect(note.hashCode, sameNote.hashCode);
  });
}
